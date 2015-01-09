class Task < ActiveRecord::Base

  has_many :task_logs

  validates :deadline, :presence => true
  validates :assigned_name, :presence => true
  validates :assigned_phone, :presence => true
  validates :state, :presence => true

  before_create :build_initial_log
  after_save :log_state

=begin
  state_machine :state, :initial => :pending do
    #twilio states: pending, sent, delivered, failed or undelivered

    after_transition :to => all do |task, transition|
      task.task_logs.create(:state => task.state)
    end

    event :queue_sms do
      transition all => :sms_queued
    end

    event :send_sms do
      transition all => :sms_sent
    end

    event :fail_sms do
      transition all => :sms_failed
    end

    event :accept do
      transition all => :accepted
    end

    event :reject do
      transition all => :rejected
    end

    event :complete do
      transition all => :completed
    end
  end
=end

  private

    def build_initial_log
      self.task_logs.build(:state => self.state)
    end

    def log_state
      if self.state_changed? or self.last_message_sid_changed? or self.last_message_state_changed? or self.last_message_changed?
        message = self.last_message_sid_changed? ? self.last_message : ""
        message_state = self.last_message_state_changed? ? self.last_message_state : ""
        self.task_logs.create(:state => self.state, :message_state => message_state, :message => message)
      end
    end

end
