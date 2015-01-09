require 'rails_helper'

RSpec.describe TwilioController, :type => :controller do
  include SmsSpec::Helpers
  include SmsSpec::Matchers

  let(:vreasy_phone) { 
    "+14244880161"
  }
  let(:worker_phone) {
    "+14244880161"
  }
  let(:valid_attributes) {
    { "deadline(1i)" => "2014", "deadline(2i)" => "12", "deadline(3i)" => "29", "deadline(4i)" => "21", "deadline(5i)" => "21", "assigned_name" => "gemma", "assigned_phone" => worker_phone, "state" => "waiting_response" }
  }

  before(:each) do
    @task = Task.create! valid_attributes
  end

  describe "POST status" do
    let(:status_params) {
      {"SmsSid"=>"SM6c23434865447b7dce7ad91c923bb518", "SmsStatus"=>"sent", "To"=>worker_phone, "From"=>vreasy_phone, "task_id"=>@task.id}
    }

    before(:each) do
      post :status, status_params
    end

    it "updates the last_message_state and last_message_sid of the task" do
      expect(assigns(:task).last_message_state).to eq(status_params['SmsStatus'])
      expect(assigns(:task).last_message_sid).to eq(status_params['SmsSid'])
    end
  end

  describe "POST sms with 'ok'" do
    let(:sms_params) {
      {"SmsSid"=>"SM894e1c2f74b483b4dbe957cc3bbd44c0", "SmsStatus"=>"received", "Body"=>"si", "To"=>vreasy_phone, "From"=>worker_phone}
    }

    before(:each) do
      @num_logs = @task.task_logs.count
      post :sms, sms_params
    end

    it "updates the task state to 'accepted'" do
      expect(assigns(:task).state).to eq('accepted')
    end

    it "updates the last_message attributes of the task" do
      expect(assigns(:task).last_message).to eq("OK, pues ya me avisaras si hay algun problema")
    end

    it "replies with a message" do
      response.body.should include("<Message>OK, pues ya me avisaras si hay algun problema</Message>")
    end

    it "adds 2 logs for the task" do
      expect(assigns(:task).task_logs.count).to eq(@num_logs + 2)
    end
  end

  describe "POST sms with 'no'" do
    let(:sms_params) {
      {"SmsSid"=>"SM894e1c2f74b483b4dbe957cc3bbd44c0", "SmsStatus"=>"received", "Body"=>"no", "To"=>vreasy_phone, "From"=>worker_phone}
    }

    before(:each) do
      @num_logs = @task.task_logs.count
      post :sms, sms_params
    end

    it "updates the task state to 'rejected'" do
      expect(assigns(:task).state).to eq('rejected')
    end

    it "updates the last_message attributes of the task" do
      expect(assigns(:task).last_message).to eq("OK, ya buscare a alguien")
    end

    it "replies with a message" do
      response.body.should include("<Message>OK, ya buscare a alguien</Message>")
    end

    it "adds 2 logs for the task" do
      expect(assigns(:task).task_logs.count).to eq(@num_logs + 2)
    end
  end

  describe "POST sms with 'some other response from the worker'" do
    let(:sms_params) {
      {"SmsSid"=>"SM894e1c2f74b483b4dbe957cc3bbd44c0", "SmsStatus"=>"received", "Body"=>"some other response from the worker", "To"=>vreasy_phone, "From"=>worker_phone}
    }

    before(:each) do
      post :sms, sms_params
    end

    it "updates the task state to 'conversation'" do
      expect(assigns(:task).state).to eq('conversation')
    end

    it "updates the last_message attributes of the task" do
      expect(assigns(:task).last_message).to eq(sms_params['Body'])
      expect(assigns(:task).last_message_state).to eq(sms_params['SmsStatus'])
      expect(assigns(:task).last_message_sid).to eq(sms_params['SmsSid'])
    end

  end

end