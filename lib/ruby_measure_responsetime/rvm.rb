# frozen_string_literal: true

# Logic to use RVM
class Rvm

  def self.ruby_manager
    if self.ruby_manager_installed?
      self
    end
  end

  def self.installed_rubies
    versions = []

    `rvm list`
      .split("\n")
      .map { |version| version.scan(/ ([a-z]+\-[\d\.\-previw]+) +.*/)&.first&.first }
      .compact
      .sort
      .each do |version|
        versions << [ version, nil ]

        if version =~ /ruby\-3.0/
          versions << [ version, '--jit']
        end

        if version =~ /ruby\-3.1/ || version =~ /ruby\-3.2/
          versions << [ version, '--mjit']
          versions << [ version, '--yjit --yjit-exec-mem-size=8']
        end

        if version =~ /ruby\-3.3/
          versions << [ version, '--rjit']
          versions << [ version, '--yjit']
        end
      end

    versions
  end

  def self.cmd_initialize_ruby_version_manager
  end

  def self.cmd_switch_to_ruby(version)
    "rvm use #{version} > /dev/null;"
  end

  private

  def self.ruby_manager_installed?
    (`rvm` =~ /\ARuby/) == 0
  rescue
    false
  end
end
