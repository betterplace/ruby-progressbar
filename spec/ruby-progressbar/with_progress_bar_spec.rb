require 'spec_helper'
require 'ruby-progressbar/with_progress_bar'

describe 'with_progress_bar' do
  let :output do
    double('output').tap do |o|
      expect(o).to receive(:print).at_least(1)
      expect(o).to receive(:flush).at_least(1)
      allow(o).to receive(:tty?).and_return true
    end
  end

  let :collection do
    [ 1, 2, 3 ]
  end

  context "deriving total" do
    before do
      Thread.current[:__progress_bar__] = nil
    end

    it "derives total from progress_bar_total method" do
      expect(progress_bar).to be_nil
      def collection.progress_bar_total
        size
      end
      expect(collection).to receive(:progress_bar_total).and_call_original
      collection.with_progress_bar(:output => output)
      expect(progress_bar.total).to eq 3
    end

    it "derives total from size" do
      expect(progress_bar).to be_nil
      class << collection
        undef_method :length
      end
      expect(collection).to receive(:size).and_call_original
      collection.with_progress_bar(:output => output)
      expect(progress_bar.total).to eq 3
    end

    it "derives total from length" do
      expect(progress_bar).to be_nil
      class << collection
        undef_method :size
      end
      expect(collection).to receive(:length).and_call_original
      collection.with_progress_bar(:output => output)
      expect(progress_bar.total).to eq 3
    end

    it "derives total from length if size returns nil" do
      expect(progress_bar).to be_nil
      class << collection
        def size
        end
      end
      expect(collection).to receive(:length).and_call_original
      collection.with_progress_bar(:output => output)
      expect(progress_bar.total).to eq 3
    end

    it "derives total from count" do
      expect(progress_bar).to be_nil
      class << collection
        old_size = instance_method(:size)
        define_method :count do
          old_size.bind(self).call
        end
        undef_method :size
        undef_method :length
      end
      expect(collection).to receive(:count).and_call_original
      collection.with_progress_bar(:output => output)
      expect(progress_bar.total).to eq 3
    end
  end

  it "works for simple iteration and block" do
    s = 0
    (0...10).with_progress_bar(:output => output) do |i|
      expect(progress_bar.progress).to eq i
      s += i
    end
    expect(progress_bar.progress).to eq 10
    expect(s).to eq 45
  end

  it "works for simple iteration" do
    s = 0
    (0...10).with_progress_bar(:output => output).each do |i|
      expect(progress_bar.progress).to eq i
      s += i
    end
    expect(progress_bar.progress).to eq 10
    expect(s).to eq 45
  end

  it "works with implicit increment and block" do
    s = 0
    (0...10).with_progress_bar(:output => output) do |i|
      expect(progress_bar.progress).to eq i
      progress_bar.increment
      s += i
    end
    expect(progress_bar.progress).to eq 10
    expect(s).to eq 45
  end

  it "works with implicit increment" do
    s = 0
    (0...10).with_progress_bar(:output => output).each do |i|
      expect(progress_bar.progress).to eq i
      progress_bar.increment
      s += i
    end
    expect(progress_bar.progress).to eq 10
    expect(s).to eq 45
  end

  it "works with slices" do
    s = 0
    for slice in (0...10).with_progress_bar(:output => output).each_slice(3)
      s += slice[0, 3].compact.reduce(:+)
    end
    expect(progress_bar.progress).to eq 10
    expect(s).to eq 45
  end

  it "works with skipping and block" do
    s = 0
    (0...10).with_progress_bar(:output => output) do |i|
      expect(progress_bar.progress).to eq i / 2
      if i % 2 == 0
        progress_bar.skip
      end
      s += i
    end
    expect(progress_bar.progress).to eq 5
    expect(s).to eq 25
  end

  it "works with skipping" do
    s = 0
    (0...10).with_progress_bar(:output => output).each do |i|
      expect(progress_bar.progress).to eq i / 2
      if i % 2 == 0
        progress_bar.skip
      end
      s += i
    end
    expect(progress_bar.progress).to eq 5
    expect(s).to eq 25
  end

  it "cannot iterate over objects that don't implement #each" do
    class << collection
      undef_method :each
    end
    expect { collection.with_progress_bar(:output => double.as_null_object) }.to raise_error TypeError
  end

  it "cannot itererate over non-duppable objects" do
    def collection.dup
      raise TypeError
    end
    expect { collection.with_progress_bar(:output => double.as_null_object) }.to raise_error TypeError
  end
end
