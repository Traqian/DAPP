# Copyright © 2008 Ian Jackson <ijackson@chiark.greenend.org.uk>
# Copyright © 2008 Canonical, Ltd.
#   written by Colin Watson <cjwatson@ubuntu.com>
# Copyright © 2008 James Westby <jw+debian@jameswestby.net>
# Copyright © 2009 Raphaël Hertzog <hertzog@debian.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

=encoding utf8

=head1 NAME

Dpkg::Vendor::Ubuntu - Ubuntu vendor class

=head1 DESCRIPTION

This vendor class customizes the behavior of dpkg scripts for Ubuntu
specific behavior and policies.

B<Note>: This is a private module, its API can change at any time.

=cut

package Dpkg::Vendor::Ubuntu 0.01;

use strict;
use warnings;

use List::Util qw(any);

use Dpkg::ErrorHandling;
use Dpkg::Gettext;
use Dpkg::Control::Types;

use parent qw(Dpkg::Vendor::Debian);

sub run_hook {
    my ($self, $hook, @params) = @_;

    if ($hook eq 'before-source-build') {
        my $src = shift @params;
        my $fields = $src->{fields};

        # check that Maintainer/XSBC-Original-Maintainer comply to
        # https://wiki.ubuntu.com/DebianMaintainerField
        if (defined($fields->{'Version'}) and defined($fields->{'Maintainer'}) and
           $fields->{'Version'} =~ /ubuntu/) {
           if ($fields->{'Maintainer'} !~ /(?:ubuntu|canonical)/i) {
               if (length $ENV{DEBEMAIL} and $ENV{DEBEMAIL} =~ /\@(?:ubuntu|canonical)\.com/) {
                   error(g_('Version number suggests Ubuntu changes, but Maintainer: does not have Ubuntu address'));
               } else {
                   warning(g_('Version number suggests Ubuntu changes, but Maintainer: does not have Ubuntu address'));
               }
           }
           unless ($fields->{'Original-Maintainer'}) {
               warning(g_('Version number suggests Ubuntu changes, but there is no XSBC-Original-Maintainer field'));
           }
        }
    } elsif ($hook eq 'package-keyrings') {
        return ($self->SUPER::run_hook($hook),
                '/usr/share/keyrings/ubuntu-archive-keyring.gpg');
    } elsif ($hook eq 'archive-keyrings') {
        return ($self->SUPER::run_hook($hook),
                '/usr/share/keyrings/ubuntu-archive-keyring.gpg');
    } elsif ($hook eq 'archive-keyrings-historic') {
        return ($self->SUPER::run_hook($hook),
                '/usr/share/keyrings/ubuntu-archive-removed-keys.gpg');
    } elsif ($hook eq 'register-custom-fields') {
        my @field_ops = $self->SUPER::run_hook($hook);
        push @field_ops, [
            'register', 'Launchpad-Bugs-Fixed',
              CTRL_FILE_CHANGES | CTRL_CHANGELOG,
        ], [
            'insert_after', CTRL_FILE_CHANGES, 'Closes', 'Launchpad-Bugs-Fixed',
        ], [
            'insert_after', CTRL_CHANGELOG, 'Closes', 'Launchpad-Bugs-Fixed',
        ];
        return @field_ops;
    } elsif ($hook eq 'post-process-changelog-entry') {
        my $fields = shift @params;

        # Add Launchpad-Bugs-Fixed field
        my $bugs = find_launchpad_closes($fields->{'Changes'} // '');
        if (scalar(@$bugs)) {
            $fields->{'Launchpad-Bugs-Fixed'} = join(' ', @$bugs);
        }
    } elsif ($hook eq 'update-buildopts') {
        my $build_opts = shift @params;
        require Dpkg::Arch;
        my $arch = Dpkg::Arch::get_host_arch();
        if (Dpkg::Arch::debarch_eq($arch, 'riscv64')) {
            $build_opts->set('nocheck', 1, 'riscv64');
        }
    } elsif ($hook eq 'update-buildprofiles') {
        my $build_profiles_ref = shift @params;
        unless(grep $_ =~ /^!?noudeb$/, @$build_profiles_ref) {
            unshift(@$build_profiles_ref, 'noudeb');
        } else {
            # Strip otherwise invalid profile name
            @$build_profiles_ref = grep { $_ ne "!noudeb" } @$build_profiles_ref;
        }
    } else {
        return $self->SUPER::run_hook($hook, @params);
    }
}

sub _lto_disabled {
    my $fn = "/usr/share/lto-disabled-list/lto-disabled-list";
    open(LIST, "<", $fn) or return;

    # get source name
    -r "debian/control" or return;
    require Dpkg::Control::Info;
    my $ctrl = Dpkg::Control::Info->new();
    my $src_fields = $ctrl->get_source();
    return unless defined $src_fields;

    my $src = "";
    foreach (keys %{$src_fields}) {
        my $v = $src_fields->{$_};
        if (m/^Source$/i) {
            $src = $v;
            last;
        }
    }
    return unless $src ne "";

    my $arch = Dpkg::Arch::get_host_arch();

    # read disabled-list
    while (<LIST>) {
        if (m/^$src\s/) {
            if (m/^$src\s.*(any|$arch)\s/) {
                close(LIST);
                return 1;
            } else {
                close(LIST);
                return;
            }
        }
    }
    close(LIST);
    return;
}

# Override Debian default features.
sub init_build_features {
    my ($self, $use_feature, $builtin_feature) = @_;

    $self->SUPER::init_build_features($use_feature, $builtin_feature);

    require Dpkg::Arch;
    my $arch = Dpkg::Arch::get_host_arch();

    if (any { $_ eq $arch } qw(amd64 arm64 ppc64el s390x)) {
        $use_feature->{optimize}{lto} = 1;
	if (_lto_disabled()) {
        	$use_feature->{optimize}{lto} = 0;
	}
    }

    if (any { $_ eq $arch } qw(amd64 arm64 riscv64 s390x)) {
        $use_feature->{qa}{framepointer} = 1;
    }
}

sub set_build_features {
    my ($self, $flags) = @_;

    $self->SUPER::set_build_features($flags);

    require Dpkg::Arch;
    my $arch = Dpkg::Arch::get_host_arch();

    if ($arch eq 'ppc64el' && $flags->get_option_value('optimize-level') != 0) {
        $flags->set_option_value('optimize-level', 3);
    }

    $flags->set_option_value('fortify-level', 3);

    # Debian enables -fstack-clash-protection but it causes troubles on armhf
    # (which are not fully analyzed as of writing this); disable it there in
    # order to have time to investigate
    if ($arch eq 'armhf') {
        # Stack clash protector only available on amd64 and arm.
        $flags->set_feature('hardening', 'stackclash', 0);
    }
}

sub add_build_flags {
    my ($self, $flags) = @_;

    my @compile_flags = qw(
        CFLAGS
        CXXFLAGS
        OBJCFLAGS
        OBJCXXFLAGS
        FFLAGS
        FCFLAGS
    );

    $self->SUPER::add_build_flags($flags);

    # Per https://wiki.ubuntu.com/DistCompilerFlags
    $flags->prepend('LDFLAGS', '-Wl,-Bsymbolic-functions');

    # In Ubuntu these flags are set by the compiler, so when disabling the
    # features we need to pass appropriate flags to disable them.
    if (!$flags->use_feature('hardening', 'stackprotectorstrong') &&
        !$flags->use_feature('hardening', 'stackprotector')) {
        my $flag = '-fno-stack-protector';
        $flags->append($_, $flag) foreach @compile_flags;
    }

    if (!$flags->use_feature('hardening', 'stackclash')) {
        my $flag = '-fno-stack-clash-protection';
        $flags->append($_, $flag) foreach @compile_flags;
    }

    if (!$flags->use_feature('hardening', 'fortify')) {
        $flags->append('CPPFLAGS', '-D_FORTIFY_SOURCE=0');
    }

    if (!$flags->use_feature('hardening', 'format')) {
        my $flag = '-Wno-format -Wno-error=format-security';
        $flags->append('CFLAGS', $flag);
        $flags->append('CXXFLAGS', $flag);
        $flags->append('OBJCFLAGS', $flag);
        $flags->append('OBJCXXFLAGS', $flag);
     }

     if (!$flags->use_feature('hardening', 'branch')) {
        my $cpu = $flags->get_option_value('hardening-branch-cpu');
        my $flag;
        if ($cpu eq 'arm64') {
            $flag = '-mbranch-protection=none';
        } elsif ($cpu eq 'amd64') {
            $flag = '-fcf-protection=none';
        }
        if (defined $flag) {
            $flags->append($_, $flag) foreach @compile_flags;
        }
    }

    # We always enable fdebug-prefix-map and (ideally) set the new
    # path as full (unless ${DEB_BUILD_DEBUGPATH} points to a relative
    # path), because (a) the DWARF spec forbids relative paths (which
    # gets mapped to DW_AT_comp_dir), and (b) it makes our debuginfod
    # service happy when indexing source code.
    if ($flags->use_feature('reproducible', 'fixfilepath')) {
        my $build_path = $flags->get_option_value('build-path');
        my $stripflag = '-fdebug-prefix-map=' . $build_path . '=.';

        if (defined $ENV{DEB_BUILD_DEBUGPATH}) {
            my $debugprefixmap = '-fdebug-prefix-map=' . $build_path . '=' . $ENV{DEB_BUILD_DEBUGPATH};

            # Strip any existing -fdebug-prefix-map flag.
            $flags->strip($_, $stripflag) foreach @compile_flags;
            $flags->append($_, $debugprefixmap) foreach @compile_flags;
        } elsif (-r 'debian/changelog') {
            require Dpkg::Changelog::Debian;
            my $pkgchangelog = Dpkg::Changelog::Debian->new(range => { "count" => 1 });
            $pkgchangelog->load('debian/changelog');
            my $chgentry = @{$pkgchangelog}[0];
            my $pkgver = $chgentry->get_version();
            my $pkgsrc = $chgentry->get_source();

            if ($pkgver ne "" && $pkgsrc ne "") {
                my $debugprefixmap = '-fdebug-prefix-map=' . $build_path . '=/usr/src/' . $pkgsrc . '-' . $pkgver;

                # Strip any existing -fdebug-prefix-map flag.
                $flags->strip($_, $stripflag) foreach @compile_flags;
                $flags->append($_, $debugprefixmap) foreach @compile_flags;
            }
        }
    }

    return;
}

=head1 PUBLIC FUNCTIONS

=over

=item $bugs = Dpkg::Vendor::Ubuntu::find_launchpad_closes($changes)

Takes one string as argument and finds "LP: #123456, #654321" statements,
which are references to bugs on Launchpad. Returns all closed bug
numbers in an array reference.

=cut

sub find_launchpad_closes {
    my $changes = shift;
    my %closes;

    while ($changes &&
          ($changes =~ /lp:\s+\#\d+(?:,\s*\#\d+)*/pig)) {
        $closes{$_} = 1 foreach (${^MATCH} =~ /\#?\s?(\d+)/g);
    }

    my @closes = sort { $a <=> $b } keys %closes;

    return \@closes;
}

=back

=head1 CHANGES

=head2 Version 0.xx

This is a semi-private module. Only documented functions are public.

=cut

1;
