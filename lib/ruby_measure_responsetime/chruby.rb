# frozen_string_literal: true

# Logic to use Chruby
class Chruby

  # Common chruby installation paths to check
  CHRUBY_PATHS = [
    '/opt/dev/sh/chruby/chruby.sh',
    '/usr/local/share/chruby/chruby.sh',
    '/usr/share/chruby/chruby.sh',
    '$HOME/.chruby/chruby.sh'
  ].freeze

  def self.ruby_manager
    self if ruby_manager_installed?
  end

  def self.installed_rubies
    versions = []

    # Get list of rubies from chruby's RUBIES array
    rubies_output = `bash -l -c "#{source_chruby_cmd} for ruby in \\${RUBIES[@]}; do basename \\$ruby; done"`

    rubies_output
      .split("\n")
      .map(&:strip)
      .select { |version| version =~ /^ruby-[\d\.\-preview]+$/ || version =~ /^[\d\.\-preview]+$/ || version =~ /^(jruby|truffleruby)[\-\+]/ }
      .compact
      .sort
      .each do |version|
        # Normalize version string - chruby might show "ruby-3.2.0" or just "3.2.0"
        normalized_version = version.start_with?('ruby-') ? version : "ruby-#{version}"

        versions << [ normalized_version, nil ]

        # JIT configuration - only including YJIT as it's the primary JIT going forward
        if normalized_version =~ /ruby[\-\+]*3\.1/
          versions << [ normalized_version, '--yjit --yjit-exec-mem-size=8']
        end

        if normalized_version =~ /ruby[\-\+]*3\.2/
          versions << [ normalized_version, '--yjit']
        end

        if normalized_version =~ /ruby[\-\+]*3\.3/ || normalized_version =~ /ruby[\-\+]*3\.4/
          versions << [ normalized_version, '--yjit']
        end

        if normalized_version =~ /ruby[\-\+]*4\.0/
          versions << [ normalized_version, '--yjit']
        end
      end

    versions
  end

  def self.cmd_initialize_ruby_version_manager
    source_chruby_cmd
  end

  def self.cmd_switch_to_ruby(version)
    # Chruby expects version without 'ruby-' prefix for MRI rubies
    # but needs full name for other rubies (jruby-, truffleruby-, etc)
    clean_version = if version.start_with?('ruby-')
      version.sub('ruby-', '')
    else
      version
    end

    # Clear bundler environment variables that interfere with chruby
    # Unlike RVM/rbenv which use shims, chruby modifies PATH and GEM_* variables directly,
    # so bundler's environment from the parent process can interfere with the ruby switch
    "unset BUNDLE_GEMFILE BUNDLE_BIN_PATH RUBYOPT BUNDLER_VERSION BUNDLE_PATH GEM_HOME GEM_PATH; chruby #{clean_version} > /dev/null;"
  end

  private

  def self.source_chruby_cmd
    CHRUBY_PATHS.map { |path| "source #{path} 2>/dev/null" }.join(' || ') + ';'
  end

  def self.ruby_manager_installed?
    system("bash -l -c '#{source_chruby_cmd} type chruby' > /dev/null 2>&1")
  rescue
    false
  end
end