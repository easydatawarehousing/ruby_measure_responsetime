# frozen_string_literal: true

# Logic to use Rbenv
class Rbenv

  def self.ruby_manager
    if self.ruby_manager_installed?
      self
    end
  end

  def self.installed_rubies
    versions = []

    `rbenv versions`
      .split("\n")
      .map { |version| version.scan(/[\* ]+([a-z\-+]*[\d\.\-previwc]+) *.*/)&.first&.first }
      .compact
      .sort
      .each do |version|
        versions << [ version, nil ]

        if version =~ /3\.0/
          versions << [ version, '--jit']
        end

        if version =~ /3\.1/
          versions << [ version, '--mjit']
          versions << [ version, '--yjit --yjit-exec-mem-size=8']
        end

        if version =~ /3\.2/
          versions << [ version, '--mjit']
          versions << [ version, '--yjit']
        end

        if version =~ /3\.3/ || version =~ /3\.4/
          versions << [ version, '--rjit']
          versions << [ version, '--yjit']
        end

        if version =~ /4\.0/
          versions << [ version, '--yjit']
        end
      end

    versions
  end

  def self.cmd_initialize_ruby_version_manager
    "eval \"$(rbenv init -)\";"
  end

  def self.cmd_switch_to_ruby(version)
    "export RBENV_VERSION=#{version};"
  end

  private

  def self.ruby_manager_installed?
    (`rbenv -v` =~ /\Arbenv/) == 0
  rescue
    false
  end
end
