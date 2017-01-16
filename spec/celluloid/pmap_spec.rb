require 'spec_helper'

describe Celluloid::Pmap do
  it 'should have a version number' do
    Celluloid::Pmap::VERSION.should_not be_nil
  end

  it 'should still map correctly' do
    [4, 5, 6, 7].map { |x| x + 1 }.should eq([5, 6, 7, 8])
  end

  it 'should have same results when pmap' do
    [4, 5, 6, 7].pmap { |x| x + 1 }.should eq([5, 6, 7, 8])
  end

  it 'should sleep in sequence for map' do
    expect do
      [1, 2, 3].map { sleep(1) }
    end.to take_approximately(3).seconds
  end

  it 'should sleep in parallel for pmap' do
    Celluloid.stub(:cores) { 4 }
    expect do
      [1, 2, 3].pmap { sleep(1) }
    end.to take_approximately(1).seconds
  end

  it 'should default to the number of cores on the machine' do
    Celluloid.stub(:cores) { 4 }
    expect do
      [1, 2, 3, 4, 5, 6].pmap { sleep(1) }
    end.to take_approximately(2).seconds
  end

  it 'can be set to many threads at once' do
    expect do
      [1, 2, 3, 4, 5, 6].pmap(10) { sleep(1) }
    end.to take_approximately(1).seconds
  end

  let(:pool) { Celluloid::Pmap::ParallelMapWorker.pool(size: 10) }
  it 'can reuse an existing thread pool' do
    expect do
      [1, 2, 3, 4, 5, 6].pmap(pool) { sleep(1) }
    end.to take_approximately(1).seconds
  end

  it 'should be included in enumerable' do
    Enumerable.ancestors.should include(Celluloid::Pmap)
  end
end
