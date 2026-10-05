# frozen_string_literal: true

require 'spec_helper'

describe 'cloudwatch' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      describe 'with default parameters' do
        it { is_expected.to compile }

        it { is_expected.to contain_class('cloudwatch') }

        it {
          is_expected.to contain_archive('CloudWatchMonitoringScripts-1.2.2.zip').with(
            path: '/tmp/CloudWatchMonitoringScripts-1.2.2.zip',
            extract: true,
            extract_path: '/opt',
            source: 'https://aws-cloudwatch.s3.amazonaws.com/downloads/CloudWatchMonitoringScripts-1.2.2.zip',
            creates: '/opt/aws-scripts-mon',
          )
        }

        it {
          is_expected.to contain_cron('cloudwatch').with(
            ensure: 'present',
            name: 'Push extra metrics to Cloudwatch',
            minute: '*',
            hour: '*',
            monthday: '*',
            month: '*',
            weekday: '*',
          )
        }

        it {
          is_expected.to contain_cron('cloudwatch').with(
            command: %r{/opt/aws-scripts-mon/mon-put-instance-data\.pl},
          )
        }

        it {
          is_expected.to contain_cron('cloudwatch').with(
            command: %r{--from-cron},
          )
        }

        it {
          is_expected.to contain_cron('cloudwatch').with(
            command: %r{--memory-units=megabytes},
          )
        }

        it {
          is_expected.to contain_cron('cloudwatch').with(
            command: %r{--disk-space-units=gigabytes},
          )
        }

        it {
          is_expected.to contain_cron('cloudwatch').with(
            command: %r{--mem-util},
          )
        }

        it {
          is_expected.to contain_cron('cloudwatch').with(
            command: %r{--mem-used},
          )
        }

        it {
          is_expected.to contain_cron('cloudwatch').with(
            command: %r{--mem-avail},
          )
        }

        it {
          is_expected.to contain_cron('cloudwatch').with(
            command: %r{--swap-util},
          )
        }

        it {
          is_expected.to contain_cron('cloudwatch').with(
            command: %r{--swap-used},
          )
        }

        it {
          is_expected.to contain_cron('cloudwatch').with(
            command: %r{--disk-path=/},
          )
        }

        it {
          is_expected.to contain_cron('cloudwatch').with(
            command: %r{--disk-space-util},
          )
        }

        it {
          is_expected.to contain_cron('cloudwatch').with(
            command: %r{--disk-space-used},
          )
        }

        it {
          is_expected.to contain_cron('cloudwatch').with(
            command: %r{--disk-space-avail},
          )
        }

        it {
          is_expected.not_to contain_cron('cloudwatch').with(
            command: %r{--aggregated(?:=|$)},
          )
        }

        it {
          is_expected.not_to contain_cron('cloudwatch').with(
            command: %r{--auto-scaling(?:=|$)},
          )
        }
      end

      describe 'package dependencies' do
        context 'with RedHat family facts' do
          let(:facts) do
            facts.merge(
              os: {
                family: 'RedHat',
                name: 'RedHat',
                release: facts.dig(:os, :release),
              },
            )
          end

          it { is_expected.to compile }

          [
            'perl-Switch',
            'perl-DateTime',
            'perl-Sys-Syslog',
            'perl-LWP-Protocol-https',
            'perl-Digest-SHA',
            'unzip',
            'cronie',
          ].each do |package|
            it {
              is_expected.to contain_package(package).with(
                ensure: 'installed',
              )
            }
          end
        end

        context 'with Amazon family facts' do
          let(:facts) do
            facts.merge(
              os: {
                family: 'Amazon',
                name: 'Amazon',
                release: facts.dig(:os, :release),
              },
            )
          end

          it { is_expected.to compile }

          [
            'perl-Switch',
            'perl-DateTime',
            'perl-Sys-Syslog',
            'perl-LWP-Protocol-https',
            'unzip',
            'cronie',
          ].each do |package|
            it {
              is_expected.to contain_package(package).with(
                ensure: 'installed',
              )
            }
          end

          it {
            is_expected.not_to contain_package('perl-Digest-SHA')
          }
        end

        context 'with Debian family facts' do
          let(:facts) do
            facts.merge(
              os: {
                family: 'Debian',
                name: 'Debian',
                release: facts.dig(:os, :release),
              },
            )
          end

          it { is_expected.to compile }

          [
            'libwww-perl',
            'libdatetime-perl',
            'unzip',
            'cronie',
          ].each do |package|
            it {
              is_expected.to contain_package(package).with(
                ensure: 'installed',
              )
            }
          end

          it {
            is_expected.not_to contain_package('perl-Switch')
          }

          it {
            is_expected.not_to contain_package('perl-DateTime')
          }

          it {
            is_expected.not_to contain_package('perl-Sys-Syslog')
          }

          it {
            is_expected.not_to contain_package('perl-LWP-Protocol-https')
          }

          it {
            is_expected.not_to contain_package('perl-Digest-SHA')
          }
        end
      end

      describe 'credentials' do
        context 'with access_key and secret_key' do
          let(:params) do
            {
              access_key: 'ACCESSKEY',
              secret_key: 'SECRETKEY',
            }
          end

          it { is_expected.to compile }

          it {
            is_expected.to contain_cron('cloudwatch').with(
              command: %r{--aws-access-key-id=ACCESSKEY},
            )
          }

          it {
            is_expected.to contain_cron('cloudwatch').with(
              command: %r{--aws-secret-key=SECRETKEY},
            )
          }

          it {
            is_expected.not_to contain_cron('cloudwatch').with(
              command: %r{--aws-credential-file=},
            )
          }

          it {
            is_expected.not_to contain_cron('cloudwatch').with(
              command: %r{--aws-iam-role=},
            )
          }
        end

        context 'with credential_file' do
          let(:params) do
            {
              credential_file: '/etc/aws/credentials',
            }
          end

          it { is_expected.to compile }

          it {
            is_expected.to contain_cron('cloudwatch').with(
              command: %r{--aws-credential-file=/etc/aws/credentials},
            )
          }

          it {
            is_expected.not_to contain_cron('cloudwatch').with(
              command: %r{--aws-access-key-id=},
            )
          }

          it {
            is_expected.not_to contain_cron('cloudwatch').with(
              command: %r{--aws-iam-role=},
            )
          }
        end

        context 'with iam_role' do
          let(:params) do
            {
              iam_role: 'my-instance-role',
            }
          end

          it { is_expected.to compile }

          it {
            is_expected.to contain_cron('cloudwatch').with(
              command: %r{--aws-iam-role=my-instance-role},
            )
          }

          it {
            is_expected.not_to contain_cron('cloudwatch').with(
              command: %r{--aws-access-key-id=},
            )
          }

          it {
            is_expected.not_to contain_cron('cloudwatch').with(
              command: %r{--aws-credential-file=},
            )
          }
        end

        context 'with no credentials' do
          it {
            is_expected.to contain_cron('cloudwatch').without(
              command: %r{--aws-access-key-id=},
            )
          }

          it {
            is_expected.to contain_cron('cloudwatch').without(
              command: %r{--aws-credential-file=},
            )
          }

          it {
            is_expected.to contain_cron('cloudwatch').without(
              command: %r{--aws-iam-role=},
            )
          }
        end
      end

      describe 'memory metrics' do
        context 'when memory utilization is disabled' do
          let(:params) do
            { enable_mem_util: false }
          end

          it {
            is_expected.to contain_cron('cloudwatch').without(
              command: %r{--mem-util},
            )
          }
        end

        context 'when memory used is disabled' do
          let(:params) do
            { enable_mem_used: false }
          end

          it {
            is_expected.to contain_cron('cloudwatch').without(
              command: %r{--mem-used},
            )
          }
        end

        context 'when memory available is disabled' do
          let(:params) do
            { enable_mem_avail: false }
          end

          it {
            is_expected.to contain_cron('cloudwatch').without(
              command: %r{--mem-avail},
            )
          }
        end

        context 'when swap utilization is disabled' do
          let(:params) do
            { enable_swap_util: false }
          end

          it {
            is_expected.to contain_cron('cloudwatch').without(
              command: %r{--swap-util},
            )
          }
        end

        context 'when swap used is disabled' do
          let(:params) do
            { enable_swap_used: false }
          end

          it {
            is_expected.to contain_cron('cloudwatch').without(
              command: %r{--swap-used},
            )
          }
        end
      end

      describe 'disk metrics' do
        context 'with multiple disk paths' do
          let(:params) do
            {
              disk_path: ['/', '/var', '/opt'],
            }
          end

          it {
            is_expected.to contain_cron('cloudwatch').with(
              command: %r{--disk-path=/ --disk-path=/var --disk-path=/opt},
            )
          }
        end

        context 'with no disk paths' do
          let(:params) do
            {
              disk_path: [],
            }
          end

          it {
            is_expected.not_to contain_cron('cloudwatch').with(
              command: %r{--disk-path=},
            )
          }
        end

        context 'when disk utilization is disabled' do
          let(:params) do
            { enable_disk_space_util: false }
          end

          it {
            is_expected.to contain_cron('cloudwatch').without(
              command: %r{--disk-space-util},
            )
          }
        end

        context 'when disk used is disabled' do
          let(:params) do
            { enable_disk_space_used: false }
          end

          it {
            is_expected.to contain_cron('cloudwatch').without(
              command: %r{--disk-space-used},
            )
          }
        end

        context 'when disk available is disabled' do
          let(:params) do
            { enable_disk_space_avail: false }
          end

          it {
            is_expected.to contain_cron('cloudwatch').without(
              command: %r{--disk-space-avail},
            )
          }
        end
      end

      describe 'units' do
        let(:params) do
          {
            memory_units: 'gigabytes',
            disk_space_units: 'megabytes',
          }
        end

        it {
          is_expected.to contain_cron('cloudwatch').with(
            command: %r{--memory-units=gigabytes},
          )
        }

        it {
          is_expected.to contain_cron('cloudwatch').with(
            command: %r{--disk-space-units=megabytes},
          )
        }
      end

      describe 'aggregation' do
        context 'when enabled' do
          let(:params) do
            { aggregated: true }
          end

          it {
            is_expected.to contain_cron('cloudwatch').with(
              command: %r{--aggregated(?:\s|$)},
            )
          }
        end

        context 'when enabled with aggregated_only' do
          let(:params) do
            {
              aggregated: true,
              aggregated_only: true,
            }
          end

          it {
            is_expected.to contain_cron('cloudwatch').with(
              command: %r{--aggregated=only},
            )
          }
        end

        context 'when aggregated_only is true without aggregated' do
          let(:params) do
            { aggregated_only: true }
          end

          it {
            is_expected.to contain_cron('cloudwatch').without(
              command: %r{--aggregated},
            )
          }
        end
      end

      describe 'Auto Scaling' do
        context 'when enabled' do
          let(:params) do
            { auto_scaling: true }
          end

          it {
            is_expected.to contain_cron('cloudwatch').with(
              command: %r{--auto-scaling(?:\s|$)},
            )
          }
        end

        context 'when enabled with auto_scaling_only' do
          let(:params) do
            {
              auto_scaling: true,
              auto_scaling_only: true,
            }
          end

          it {
            is_expected.to contain_cron('cloudwatch').with(
              command: %r{--auto-scaling=only},
            )
          }
        end

        context 'when auto_scaling_only is true without auto_scaling' do
          let(:params) do
            { auto_scaling_only: true }
          end

          it {
            is_expected.to contain_cron('cloudwatch').without(
              command: %r{--auto-scaling},
            )
          }
        end
      end

      describe 'cron' do
        context 'with a custom minute' do
          let(:params) do
            { cron_min: '*/5' }
          end

          it {
            is_expected.to contain_cron('cloudwatch').with(
              minute: '*/5',
            )
          }
        end
      end

      describe 'installation' do
        context 'with a custom install target' do
          let(:params) do
            { install_target: '/usr/local' }
          end

          it {
            is_expected.to contain_archive('CloudWatchMonitoringScripts-1.2.2.zip').with(
              extract_path: '/usr/local',
              creates: '/usr/local/aws-scripts-mon',
            )
          }

          it {
            is_expected.to contain_cron('cloudwatch').with(
              command: %r{/usr/local/aws-scripts-mon/mon-put-instance-data\.pl},
            )
          }
        end
      end

      describe 'dependency management' do
        context 'when disabled' do
          let(:params) do
            { manage_dependencies: false }
          end

          it { is_expected.to compile }

          it { is_expected.not_to contain_package('unzip') }
          it { is_expected.not_to contain_package('perl-Switch') }
          it { is_expected.not_to contain_package('cronie') }

          it {
            is_expected.to contain_archive('CloudWatchMonitoringScripts-1.2.2.zip')
          }

          it {
            is_expected.to contain_cron('cloudwatch')
          }
        end

        context 'when enabled' do
          it {
            is_expected.to contain_archive('CloudWatchMonitoringScripts-1.2.2.zip').that_requires(
              'Package[unzip]',
            )
          }

          it {
            is_expected.to contain_cron('cloudwatch').that_requires(
              'Archive[CloudWatchMonitoringScripts-1.2.2.zip]',
            )
          }
        end
      end
    end
  end

  describe 'credential validation' do
    let(:facts) do
      {
        os: {
          family: 'RedHat',
          name: 'RedHat',
          release: {
            major: '9',
            minor: '0',
            full: '9.0',
          },
        },
      }
    end

    context 'with access_key but without secret_key' do
      let(:params) do
        { access_key: 'ACCESSKEY' }
      end

      it { is_expected.to compile }

      it {
        is_expected.to contain_cron('cloudwatch').without(
          command: %r{--aws-access-key-id=ACCESSKEY},
        )
      }
    end

    context 'with secret_key but without access_key' do
      let(:params) do
        { secret_key: 'SECRETKEY' }
      end

      it { is_expected.to compile }

      it {
        is_expected.to contain_cron('cloudwatch').without(
          command: %r{--aws-secret-key=SECRETKEY},
        )
      }
    end

    context 'with access_key, secret_key, and credential_file' do
      let(:params) do
        {
          access_key: 'ACCESSKEY',
          secret_key: 'SECRETKEY',
          credential_file: '/etc/aws/credentials',
        }
      end

      it {
        is_expected.to compile.and_raise_error(
          %r{\$access_key and \$secret_key cannot be used with \$credential_file},
        )
      }
    end

    context 'with access_key, secret_key, and iam_role' do
      let(:params) do
        {
          access_key: 'ACCESSKEY',
          secret_key: 'SECRETKEY',
          iam_role: 'my-role',
        }
      end

      it {
        is_expected.to compile.and_raise_error(
          %r{\$access_key and \$secret_key cannot be used with \$iam_role},
        )
      }
    end

    context 'with credential_file and iam_role' do
      let(:params) do
        {
          credential_file: '/etc/aws/credentials',
          iam_role: 'my-role',
        }
      end

      it {
        is_expected.to compile.and_raise_error(
          %r{\$credential_file cannot be used with \$iam_role},
        )
      }
    end
  end

  describe 'unsupported operating system' do
    let(:facts) do
      {
        os: {
          family: 'Solaris',
          name: 'Solaris',
          release: {
            major: '11',
            minor: '4',
            full: '11.4',
          },
        },
      }
    end

    it {
      is_expected.to compile.and_raise_error(
        %r{Dependency management for module cloudwatch is not supported on Solaris},
      )
    }
  end
end
