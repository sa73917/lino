require 'open4'
require 'stringio'
require 'spec_helper'

describe Lino::CommandLine do
  it 'executes the command line with an empty stdin and default stdout and stderr when not provided' do
    command = 'ls -la'
    command_line = Lino::CommandLine.new(command)

    expect(Open4).to(
        receive(:spawn).with(
            command,
            stdin: '',
            stdout: STDOUT,
            stderr: STDERR))

    command_line.execute
  end

  it 'uses the supplied stdin, stdout and stderr when provided' do
    command = 'ls -la'
    command_line = Lino::CommandLine.new(command)

    stdin = 'hello'
    stdout = StringIO.new
    stderr = StringIO.new

    expect(Open4).to(
        receive(:spawn).with(
            command,
            stdin: stdin,
            stdout: stdout,
            stderr: stderr))

    command_line.execute(
        stdin: stdin,
        stdout: stdout,
        stderr: stderr)
  end
end
