require 'yaml'
require 'rake_circle_ci'
require 'rake_github'
require 'rake_ssh'
require 'rake_gpg'
require 'securerandom'
require 'rspec/core/rake_task'

task :default => :spec

RSpec::Core::RakeTask.new(:spec)

namespace :encryption do
  namespace :passphrase do
    task :generate do
      File.open('config/secrets/ci/encryption.passphrase', 'w') do |f|
        f.write(SecureRandom.base64(36))
      end
    end
  end
end

namespace :keys do
  namespace :deploy do
    RakeSSH.define_key_tasks(
        path: 'config/secrets/ci/',
        comment: 'maintainers@infrablocks.io')
  end

  namespace :gpg do
    RakeGPG.define_generate_key_task(
        output_directory: 'config/secrets/ci',
        name_prefix: 'gpg',
        owner_name: 'InfraBlocks Maintainers',
        owner_email: 'maintainers@infrablocks.io',
        owner_comment: 'lino CI Key')
  end
end

RakeCircleCI.define_project_tasks(
    namespace: :circle_ci,
    project_slug: 'github/infrablocks/lino'
) do |t|
  circle_ci_config =
      YAML.load_file('config/secrets/circle_ci/config.yaml')

  t.api_token = circle_ci_config["circle_ci_api_token"]
  t.environment_variables = {
      ENCRYPTION_PASSPHRASE:
          File.read('config/secrets/ci/encryption.passphrase')
              .chomp
  }
  t.checkout_keys = []
  t.ssh_keys = [
      {
          hostname: "github.com",
          private_key: File.read('config/secrets/ci/ssh.private')
      }
  ]
end

RakeGithub.define_repository_tasks(
    namespace: :github,
    repository: 'infrablocks/lino',
) do |t|
  github_config =
      YAML.load_file('config/secrets/github/config.yaml')

  t.access_token = github_config["github_personal_access_token"]
  t.deploy_keys = [
      {
          title: 'CircleCI',
          public_key: File.read('config/secrets/ci/ssh.public')
      }
  ]
end

namespace :pipeline do
  task :prepare => [
      :'circle_ci:project:follow',
      :'circle_ci:env_vars:ensure',
      :'circle_ci:checkout_keys:ensure',
      :'circle_ci:ssh_keys:ensure',
      :'github:deploy_keys:ensure'
  ]
end

namespace :version do
  desc "Bump version for specified type (pre, major, minor, patch)"
  task :bump, [:type] do |_, args|
    bump_version_for(args.type)
  end
end

desc "Release gem"
task :release do
  sh "gem release --tag --push"
end

def bump_version_for(version_type)
  sh "gem bump --version #{version_type} " +
      "&& bundle install " +
      "&& export LAST_MESSAGE=\"$(git log -1 --pretty=%B)\" " +
      "&& git commit -a --amend -m \"${LAST_MESSAGE} [ci skip]\""
end
