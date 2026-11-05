# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DemoSeedData do
  it 'refuses to seed a database that is not the explicitly isolated development demo' do
    expect { described_class.new.call }.to raise_error(ArgumentError, /separate.*demo/)
    expect(Account.count).to eq(0)
    expect(Lodging.count).to eq(0)
  end
end
