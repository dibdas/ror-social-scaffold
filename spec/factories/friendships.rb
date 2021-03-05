FactoryBot.define do
  factory :friendship do
    sender
    receiver
    status { 'accepted' }

    trait :pending do
      status { 'pending' }
    end
  end
end
