require_relative '../test'
require 'brakeman/differ'

class DifferTests < Minitest::Test
  include BrakemanTester::DiffHelper

  def setup
    @@diffrun ||= Brakeman.run :app_path => "#{TEST_PATH}/apps/rails2"
    @warnings ||= @@diffrun.warnings
  end

  def run_diff new, old
    @diff = Brakeman::Differ.new(new, old).diff
  end

  def assert_fixed expected, diff = @diff
    assert_equal expected, diff[:fixed].length, "Expected #{expected} fixed warnings, but found #{diff[:fixed].length}"
  end

  def assert_new expected, diff = @diff
    assert_equal expected, diff[:new].length, "Expected #{expected} new warnings, but found #{diff[:new].length}"
  end

  def test_sanity
    run_diff @warnings, @warnings

    assert_fixed 0
    assert_new 0
  end

  def test_one_fixed
    old = @warnings
    new = @warnings.dup
    new.shift

    run_diff new, old

    assert_fixed 1
    assert_new 0
  end

  def test_one_new
    new = @warnings
    old = @warnings.dup
    old.shift

    run_diff new, old

    assert_fixed 0
    assert_new 1
  end

  def test_new_and_fixed
    new = @warnings
    old = @warnings.dup

    new << old.pop
    old << new.shift

    run_diff new, old

    assert_new 2
    assert_fixed 2
  end

  def test_line_number_change_only
    new = @warnings
    old = @warnings.dup

    changed = new.pop.dup
    if changed.line.nil?
      changed.instance_variable_set(:@line, 0)
    else
      changed.instance_variable_set(:@line, changed.line + 1)
    end

    new << changed

    run_diff new, old

    assert_new 0
    assert_fixed 0
  end
end
