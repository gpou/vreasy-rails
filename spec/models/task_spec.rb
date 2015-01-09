require 'rails_helper'

RSpec.describe Task, :type => :model do
  subject { Task.new }
  it { should have_many(:task_logs) }
  it { should validate_presence_of(:deadline) }
  it { should validate_presence_of(:assigned_name) }
  it { should validate_presence_of(:assigned_phone) }
  it { should validate_presence_of(:state) }
end
