defmodule SqsServiceSpec do
  use ESpec
  alias SqsService
  alias SqsService.Message

  describe "process_message/1" do
    let queue_name: "23445756765/test-queue"

    context "No message received" do
      let sqs_response: {:ok, %{body: %{message: nil}}}
      subject do: SqsService.process_message(sqs_response(), queue_name())

      it "returns a :no_message tuple" do
        expect subject() |> to(eq {:no_message, nil})
      end
    end

    context "SQS Message" do
      let ex_aws_response: %{
        messages: [%{
          receipt_handle: "dc41fb8c0872b2fcba8084a2fe082861",
          message_id: "34c9a3f2-05fd-4293-a88c-cbf686230745",
          body: ~s"""
              {
                \"type\":\"requires-708\",\"email\":\"joff@joff.codes\",\"first_name\":\"Joff\",
                \"raising_name\":\"SpaceXMarsLanderBakeSale\",\"raising_slug\":\"spacex-bake-sale\"
              }
          """
        }]
      }

      let sqs_response: {:ok, %{body: ex_aws_response()}}
      subject do: SqsService.process_message(sqs_response(), queue_name())

      let_ok :payload, do: subject()

      it "returns a Message Struct" do
        expect payload() |> to(be_struct Message)
      end

      it "extracts the receipt handle from the sqs message" do
        expect payload().receipt_handle |> to(eq "dc41fb8c0872b2fcba8084a2fe082861")
      end

      it "extracts the message id from the sqs message" do
        expect payload().message_id |> to(eq "34c9a3f2-05fd-4293-a88c-cbf686230745")
      end

      it "converts the body json into a hash with string keys" do
        expect payload().body["type"] |> to(eq "requires-708")
      end
    end

    context "SNS Message" do
      let ex_aws_response: %{
            messages: [%{
              message_id: "2849858e-fa3b-4331-a962-5ba9cc87324e",
              receipt_handle: "AQEB7oMmMBzaLnGepJI2vTfCFpdHb4BDEeg",
              body: ~S"""
                {
                "Type" : "Notification",
                "MessageId" : "eb9a8276-41c5-5985-883f-d2e5cc82ef0d",
                "TopicArn" : "arn:aws:sns:ap-southeast-2:038451313208:test-accountant",
                "Message" : "{       \"type\":           \"s708-upload\",       \"email\":          \"info@raisebook.com\",         \"investor_name\":  \"test\",        \"investor_email\": \"test@investor.email\"}",
                "Timestamp" : "2016-11-02T06:43:19.744Z",
                "SignatureVersion" : "1",
                "Signature" : "OKsIKUqPN3O15+1m4uMyQzhLdeySrkXOlmWNT+Jber1OV3QCAXRmx+EYSeBsGKPM8Cv14r+7xN6OpvxG1xtfWtUXW7ISm4EDGGUTRirYiK8Oge8TZRqLg3b7Q18J2j9ew5RDcQQwpso8JjSMc/l1P9yPW9iDPjZx/+KJWzZeeorJYzFZcqeJAZv84F+Q0KN7Umqyf5b+eQZB+6bS/0BVHNlpoiBHQ6JuMroSCvOUFlO595szZZQQlhTqVT8rwqfw/KdfwXZTff7SqXZ1q3AdezXSfs3kG2kalCYvBC4oufJtdyce5RSVT3Mm5pXNRBY/lg3Hn60KwPj1RhHfWeCuXQ==",
                "SigningCertURL" : "https://sns.ap-southeast-2.amazonaws.com/SimpleNotificationService-b95095beb82e8f6a046b3aafc7f4149a.pem",
                "UnsubscribeURL" : "https://sns.ap-southeast-2.amazonaws.com/?Action=Unsubscribe&SubscriptionArn=arn:aws:sns:ap-southeast-2:038451313208:test-accountant:d964dcea-3269-4eeb-8482-08b977ee36b3"
              }
              """
          }]
        }

      let sqs_response: {:ok, %{body: ex_aws_response()}}
      subject do: SqsService.process_message(sqs_response(), queue_name())

      let_ok :payload, do: subject()

      it "extracts the receipt handle from the sqs message" do
        expect payload().receipt_handle |> to(eq "AQEB7oMmMBzaLnGepJI2vTfCFpdHb4BDEeg")
      end

      it "extracts the message id from the sqs message" do
        expect payload().message_id |> to(eq "2849858e-fa3b-4331-a962-5ba9cc87324e")
      end

      it "converts the body json into a hash with string keys" do
        expect payload().body["type"] |> to(eq "s708-upload")
      end
    end

  end
end
