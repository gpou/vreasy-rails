require 'rails_helper'

RSpec.describe TaskLog, :type => :model do
  subject { TaskLog.new }
  it { should belong_to(:task) }
end
