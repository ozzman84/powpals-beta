# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'home/index.html.tailwindcss', type: :view do
  it "does something" do
    visit root_path

    expect(page).to match(/Home/)
  end
end
