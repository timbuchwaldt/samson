require_relative '../../test_helper'
require 'executor/shell'

describe Executor::Shell do
  subject do
    Executor::Shell.new.tap do |shell|
      shell.output do |line|
        stdout << line
      end

      shell.error_output do |line|
        stderr << line
      end
    end
  end

  let(:stdout) { [] }
  let(:stderr) { [] }

  describe 'stdout' do
    before do
      subject.execute!('echo "hi"', 'echo "hello"')
    end

    it 'keeps all lines' do
      stdout.must_equal(%w{hi hello})
      stderr.must_equal([])
    end
  end

  describe 'stderr' do
    before do
      subject.execute!('echo "hi" >&2', 'echo "hello" >&2')
    end

    it 'keeps all lines' do
      stderr.must_equal(%w{hi hello})
      stdout.must_equal([])
    end
  end

  describe 'command failures' do
    before do
      subject.execute!('ls /nonexistent/place', 'echo "hi"')
    end

    it 'does not execute the other commands' do
      stdout.must_be_empty
      stderr.must_equal([
        "ls: cannot access /nonexistent/place: No such file or directory",
        "Failed to execute \"ls /nonexistent/place\""
      ])
    end
  end

  describe '#stop!' do
    it 'properly kills the execution' do
      thr = Thread.new(subject) do |shell|
        sleep(1) until shell.pid
        shell.stop!
      end

      Timeout.timeout(5) do
        subject.execute!('sleep 100').must_equal(false)
      end
    end
  end

  it 'correctly returns error value' do
    subject.execute!('blah').must_equal(false)
  end

  it 'correctly returns success value' do
    subject.execute!('echo "hi"').must_equal(true)
  end
end