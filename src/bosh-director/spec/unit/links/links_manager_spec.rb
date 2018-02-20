require 'spec_helper'

describe Bosh::Director::Links::LinksManager do
  subject {Bosh::Director::Links::LinksManager.new(logger, event_logger)}

  let(:logger) {Logging::Logger.new('TestLogger')}
  let(:event_logger) {Bosh::Director::EventLog::Log.new}

  let(:deployment_model) do
    Bosh::Director::Models::Deployment.create(
      name: 'test_deployment'
    )
  end

  describe '#add_provider' do
    context
  end

  describe '#find_or_create_provider' do
    it 'returns the existing provider' do
      expected_provider = Bosh::Director::Models::Links::LinkProvider.create(
        deployment: deployment_model,
        instance_group: 'control_instance_group',
        name: 'control_owner_object_name',
        type: 'control_owner_object_type'
      )

      actual_provider = subject.find_or_create_provider(
        deployment_model: deployment_model,
        instance_group_name: 'control_instance_group',
        name: 'control_owner_object_name',
        type: 'control_owner_object_type'
      )

      expect(actual_provider).to eq(expected_provider)
    end

    context 'link provider does not exist' do
      it 'creates a new provider' do
        expected_provider = subject.find_or_create_provider(
          deployment_model: deployment_model,
          instance_group_name: 'new_instance_group',
          name: 'new_owner_object_name',
          type: 'new_owner_object_type'
        )

        actual_provider = Bosh::Director::Models::Links::LinkProvider.find(
          deployment: deployment_model,
          instance_group: 'new_instance_group',
          name: 'new_owner_object_name',
          type: 'new_owner_object_type'
        )

        expect(actual_provider).to eq(expected_provider)
      end
    end
  end

  describe '#find_provider' do
    context 'link provider exists' do
      it 'returns the existing provider' do
        expected_provider = Bosh::Director::Models::Links::LinkProvider.create(
          deployment: deployment_model,
          instance_group: 'control_instance_group',
          name: 'control_owner_object_name',
          type: 'control_owner_object_type'
        )

        actual_provider = subject.find_provider(
          deployment_model: deployment_model,
          instance_group_name: "control_instance_group",
          name: "control_owner_object_name",
          type: "control_owner_object_type"
        )
        expect(actual_provider).to eq(expected_provider)
      end
    end

    context 'link provider does not exist' do
      it 'does not return a provider' do
        actual_provider = subject.find_provider(
          deployment_model: deployment_model,
          instance_group_name: "control_instance_group",
          name: "control_owner_object_name",
          type: "control_owner_object_type"
        )
        expect(actual_provider).to be_nil
      end
    end
  end

  describe '#find_or_create_provider_intent' do
    let(:link_provider) do
      Bosh::Director::Models::Links::LinkProvider.create(
        deployment: deployment_model,
        name: 'test_deployment',
        type: 'test_deployment_type',
        instance_group: 'test_instance_group'
      )
    end

    context 'intent already exists' do
      it 'returns the existing link_provider_intent' do
        expected_intent = Bosh::Director::Models::Links::LinkProviderIntent.create(
          link_provider: link_provider,
          original_name: 'test_original_link_name',
          type: 'test_link_type',
          name: 'test_link_alias',
          content: 'test_link_content',
          shared: false,
          consumable: true
        )

        actual_intent = subject.find_or_create_provider_intent(
          link_provider: link_provider,
          link_original_name: "test_original_link_name",
          link_type: "test_link_type"
        )

        expect(actual_intent).to eq(expected_intent)
      end
    end

    context 'intent is missing' do
      it 'creates a new link_provider_intent' do
        expect(Bosh::Director::Models::Links::LinkProviderIntent.count).to eq(0)

        actual_intent = subject.find_or_create_provider_intent(
          link_provider: link_provider,
          link_original_name: "test_original_link_name",
          link_type: "test_link_type"
        )

        expected_intent = Bosh::Director::Models::Links::LinkProviderIntent.find(
          link_provider: link_provider,
          original_name: "test_original_link_name",
          type: "test_link_type",
          shared: false,
          consumable: true
        )

        expect(Bosh::Director::Models::Links::LinkProviderIntent.count).to eq(1)
        expect(actual_intent).to eq(expected_intent)
      end
    end
  end

  describe '#find_provider_intent_*' do
    let(:link_provider) do
      Bosh::Director::Models::Links::LinkProvider.create(
        deployment: deployment_model,
        name: 'test_deployment',
        type: 'test_deployment_type',
        instance_group: 'test_instance_group'
      )
    end

    context 'when searching by alias' do
      context 'intent already exist' do
        it 'returns the existing link_provider_intent' do
          expected_intent = Bosh::Director::Models::Links::LinkProviderIntent.create(
            link_provider: link_provider,
            original_name: 'test_original_link_name',
            type: 'test_link_type',
            name: 'test_link_alias',
            content: 'test_link_content',
            shared: false,
            consumable: true
          )

          actual_intent = subject.find_provider_intent_by_alias(
            link_provider: link_provider,
            link_alias: 'test_link_alias',
            link_type: "test_link_type"
          )

          expect(actual_intent).to eq(expected_intent)
        end
      end

      context 'intent is missing' do
        it 'does not return a link_provider_intent' do
          actual_intent = subject.find_provider_intent_by_alias(
            link_provider: link_provider,
            link_alias: "test_link_alias",
            link_type: "test_link_type"
          )

          expect(actual_intent).to be_nil
        end
      end
    end

  end

  describe '#find_or_create_consumer' do
    let!(:control_consumer) do
      Bosh::Director::Models::Links::LinkConsumer.create(
        deployment: deployment_model,
        instance_group: 'control_instance_group',
        name: 'control_owner_object_name',
        type: 'control_owner_object_type'
      )
    end

    it 'finds the consumer' do
      actual_consumer = subject.find_or_create_consumer(
        deployment_model: deployment_model,
        instance_group_name: 'control_instance_group',
        name: 'control_owner_object_name',
        type: 'control_owner_object_type'
      )

      expect(actual_consumer).to eq(control_consumer)
    end

    context 'consumer does not exist' do
      it 'creates a new consumer' do
        expected_consumer = subject.find_or_create_consumer(
          deployment_model: deployment_model,
          instance_group_name: 'my_instance_group',
          name: 'my_owner_object_name',
          type: 'my_owner_object_type'
        )

        actual_consumer = Bosh::Director::Models::Links::LinkConsumer.find(
          deployment: deployment_model,
          instance_group: 'my_instance_group',
          name: 'my_owner_object_name',
          type: 'my_owner_object_type'
        )

        expect(actual_consumer).to eq(expected_consumer)
      end
    end

  end

  describe '#find_or_create_consumer_intent' do
    let(:link_consumer) do
      Bosh::Director::Models::Links::LinkConsumer.create(
        deployment: deployment_model,
        name: 'test_deployment',
        type: 'test_deployment_type',
        instance_group: 'test_instance_group'
      )
    end

    context 'intent already exist' do
      it 'returns the existing link_consumer_intent' do
        expected_link_consumer_intent = Bosh::Director::Models::Links::LinkConsumerIntent.create(
          link_consumer: link_consumer,
          original_name: 'test_original_link_name',
          type: 'test_link_type',
          optional: false,
          blocked: false
        )

        actual_link_consumer_intent = subject.find_or_create_consumer_intent(
          link_consumer: link_consumer,
          link_original_name: 'test_original_link_name',
          link_type: 'test_link_type'
        )

        expect(actual_link_consumer_intent).to eq(expected_link_consumer_intent)
      end
    end

    context 'intent is missing' do
      it 'creates a new link_consumer_intent' do
        expected_intent = subject.find_or_create_consumer_intent(
          link_consumer: link_consumer,
          link_original_name: 'test_original_link_name',
          link_type: 'test_link_type'
        )

        actual_intent = Bosh::Director::Models::Links::LinkConsumerIntent.find(
          link_consumer: link_consumer,
          original_name: 'test_original_link_name',
          type: 'test_link_type',
          optional: false,
          blocked: false
        )

        expect(actual_intent).to eq(expected_intent)
      end
    end
  end

  describe '#find_consumer' do
    context 'link consumer exists' do
      it 'returns the existing consumer' do
        expected_consumer = Bosh::Director::Models::Links::LinkConsumer.create(
          deployment: deployment_model,
          instance_group: 'control_instance_group',
          name: 'control_owner_object_name',
          type: 'control_owner_object_type'
        )

        actual_consumer = subject.find_consumer(
          deployment_model: deployment_model,
          instance_group_name: "control_instance_group",
          name: "control_owner_object_name",
          type: 'control_owner_object_type'
        )
        expect(actual_consumer).to eq(expected_consumer)
      end
    end

    context 'link consumer does not exist' do
      it 'does not return a consumer' do
        actual_consumer = subject.find_consumer(
          deployment_model: deployment_model,
          instance_group_name: "control_instance_group",
          name: "control_owner_object_name",
          type: 'job'
        )
        expect(actual_consumer).to be_nil
      end
    end
  end

  describe '#find_link' do
    let(:provider) do
      Bosh::Director::Models::Links::LinkProvider.create(
        deployment: deployment_model,
        name: 'test_provider',
        type: 'job',
        instance_group: 'test_instance_group'
      )
    end

    let(:provider_intent) do
      Bosh::Director::Models::Links::LinkProviderIntent.create(
        link_provider: provider,
        original_name: 'test_original_link_name',
        type: 'test_link_type',
        name: 'test_link_alias',
        content: '{}',
        shared: false,
        consumable: true
      )
    end

    let(:consumer) do
      Bosh::Director::Models::Links::LinkConsumer.create(
        deployment: deployment_model,
        name: 'test_consumer',
        type: 'job',
        instance_group: 'test_instance_group'
      )
    end

    let(:consumer_intent) do
      Bosh::Director::Models::Links::LinkConsumerIntent.create(
        link_consumer: consumer,
        original_name: 'test_original_link_name',
        type: 'test_link_type',
        optional: false,
        blocked: false
      )
    end

    context 'link exists' do
      it 'returns the existing link' do
        expected_link = Bosh::Director::Models::Links::Link.create(
          link_provider_intent: provider_intent,
          link_consumer_intent: consumer_intent,
          name: 'test_original_link_name',
          link_content: '{}'
        )

        actual_link = subject.find_link(
          name: 'test_original_link_name',
          provider_intent: provider_intent,
          consumer_intent: consumer_intent
        )

        expect(actual_link).to eq(expected_link)
      end
    end

    context 'link does not exist' do
      it 'does not return a link' do
        actual_link = subject.find_link(
          name: 'test_original_link_name',
          provider_intent: provider_intent,
          consumer_intent: consumer_intent
        )
        expect(actual_link).to be_nil
      end
    end
  end

  describe '#find_or_create_link' do
    let(:link_provider) do
      Bosh::Director::Models::Links::LinkProvider.create(
        deployment: deployment_model,
        name: 'test_deployment',
        type: 'test_deployment_type',
        instance_group: 'test_instance_group'
      )
    end
    let(:link_consumer) do
      Bosh::Director::Models::Links::LinkConsumer.create(
        deployment: deployment_model,
        name: 'test_deployment',
        type: 'test_deployment_type',
        instance_group: 'test_instance_group'
      )
    end
    let(:provider_intent) do
      Bosh::Director::Models::Links::LinkProviderIntent.create(
        link_provider: link_provider,
        original_name: 'test_original_link_name',
        type: 'test_link_type',
        name: 'test_link_alias',
        content: 'test_link_content',
        shared: false,
        consumable: true
      )
    end
    let(:consumer_intent) do
      Bosh::Director::Models::Links::LinkConsumerIntent.create(
        link_consumer: link_consumer,
        original_name: 'test_original_link_name',
        type: 'test_link_type',
        optional: false,
        blocked: false
      )
    end


    it 'creates a new link' do
      expected_link = subject.find_or_create_link(
        name: "test_link_name",
        provider_intent: provider_intent,
        consumer_intent: consumer_intent,
        link_content: "{}"
      )

      actual_link = Bosh::Director::Models::Links::Link.find(
        name: "test_link_name"
      )

      expect(actual_link).to eq(expected_link)
    end
  end

  describe '#resolve_deployment_links' do
    let(:global_use_dns_entry) {true}

    let(:options) do
      {
        :global_use_dns_entry => global_use_dns_entry,
        :dry_run => dry_run
      }
    end

    context 'when dry_run flag is true' do
      let(:dry_run) {true}

      context 'when it is an explicit consumer' do
        let(:consumer) do
          Bosh::Director::Models::Links::LinkConsumer.create(
            deployment: deployment_model,
            instance_group: 'ig1',
            name: 'c1',
            type: 'job'
          )
        end

        let(:metadata) do
          {'explicit_link' => true}
        end

        before do
          Bosh::Director::Models::Links::LinkConsumerIntent.create(
            link_consumer: consumer,
            original_name: 'ci1',
            name: 'provider_alias',
            type: 'foo',
            metadata: metadata.to_json
          )
        end

        context 'and the provider exists' do
          before do
            provider = Bosh::Director::Models::Links::LinkProvider.create(
              deployment: deployment_model,
              instance_group: 'ig1',
              name: 'p1',
              type: 'job'
            )

            Bosh::Director::Models::Links::LinkProviderIntent.create(
              link_provider: provider,
              original_name: 'pi1',
              name: 'provider_alias',
              type: 'foo'
            )
          end

          it 'does not create a link' do
            expect(deployment_model.link_consumers.count).to be > 0
            subject.resolve_deployment_links(deployment_model, options)
            expect(Bosh::Director::Models::Links::Link.count).to eq(0)
          end
        end

        context 'and the provider does NOT exist' do
          it 'raises an error' do
            expect(deployment_model.link_consumers.count).to be > 0

            expect {
              subject.resolve_deployment_links(deployment_model, options)
            }.to raise_error("Failed to resolve links from deployment 'test_deployment'. See errors below:\n  - Can't resolve link 'provider_alias' for job 'c1' in instance group 'ig1' in deployment 'test_deployment'")
          end

          context 'when link consumer intent is optional' do
            before do
              link_consumer_intent = Bosh::Director::Models::Links::LinkConsumerIntent.find(
                link_consumer: consumer,
                original_name: 'ci1',
                type: 'foo'
              )

              link_consumer_intent.optional = true
              link_consumer_intent.save
            end

            it 'should raise an error' do
              expect(consumer.find_intent_by_name('ci1').optional).to eq(true)

              expect {
                subject.resolve_deployment_links(deployment_model, options)
              }.to raise_error("Failed to resolve links from deployment 'test_deployment'. See errors below:\n  - Can't resolve link 'provider_alias' for job 'c1' in instance group 'ig1' in deployment 'test_deployment'")

              expect(Bosh::Director::Models::Links::Link.count).to eq(0)
            end
          end
        end

        context 'and the providers are ambiguous' do
          let(:provider_intent_1_content) {nil}
          let(:provider_intent_2_content) {nil}

          before do
            provider = Bosh::Director::Models::Links::LinkProvider.create(
              deployment: deployment_model,
              instance_group: 'ig1',
              name: 'p1',
              type: 'job'
            )

            Bosh::Director::Models::Links::LinkProviderIntent.create(
              link_provider: provider,
              original_name: 'pi1',
              name: 'provider_alias',
              type: 'foo',
              content: provider_intent_1_content
            )

            Bosh::Director::Models::Links::LinkProviderIntent.create(
              link_provider: provider,
              original_name: 'pi2',
              name: 'provider_alias',
              type: 'foo',
              content: provider_intent_2_content
            )
          end

          it 'raises an error' do
            expect {
              expect(deployment_model.link_consumers.count).to be > 0
              subject.resolve_deployment_links(deployment_model, options)
            }.to raise_error("Failed to resolve links from deployment 'test_deployment'. See errors below:\n  - Multiple providers of name/alias 'provider_alias' found for job 'c1' in instance group 'ig1'. All of these match:
   pi1 aliased as 'provider_alias' (job: p1, instance group: ig1)
   pi2 aliased as 'provider_alias' (job: p1, instance group: ig1)")
          end

          context 'when the providers are from different networks' do
            let(:provider_intent_1_content) do
              {networks: ['foo'], instances: []}.to_json
            end

            let(:provider_intent_2_content) do
              {networks: ['bar'], instances: []}.to_json
            end

            context 'and the consumer is requesting for a specific newtwork' do
              let(:metadata) do
                {
                  'explicit_link' => true,
                  'network' => 'bar'
                }
              end

              it 'should raise an error' do
                expect {
                  expect(deployment_model.link_consumers.count).to be > 0
                  subject.resolve_deployment_links(deployment_model, options)
                }.to raise_error("Failed to resolve links from deployment 'test_deployment'. See errors below:\n  - Multiple providers of name/alias 'provider_alias' found for job 'c1' in instance group 'ig1'. All of these match:
   pi1 aliased as 'provider_alias' (job: p1, instance group: ig1)
   pi2 aliased as 'provider_alias' (job: p1, instance group: ig1)")
              end
            end
          end

          context 'when link consumer intent is optional' do
            before do
              link_consumer_intent = Bosh::Director::Models::Links::LinkConsumerIntent.find(
                link_consumer: consumer,
                original_name: 'ci1',
                type: 'foo',
                )

              link_consumer_intent.optional = true
              link_consumer_intent.save
            end

            it 'raises an error' do
              expect(consumer.find_intent_by_name('ci1').optional).to eq(true)

              expect {
                subject.resolve_deployment_links(deployment_model, options)
              }.to raise_error("Failed to resolve links from deployment 'test_deployment'. See errors below:\n  - Multiple providers of name/alias 'provider_alias' found for job 'c1' in instance group 'ig1'. All of these match:
   pi1 aliased as 'provider_alias' (job: p1, instance group: ig1)
   pi2 aliased as 'provider_alias' (job: p1, instance group: ig1)")

              expect(Bosh::Director::Models::Links::Link.count).to eq(0)
            end
          end
        end
      end

      context 'when it is an implicit consumer' do
        let(:consumer) do
          Bosh::Director::Models::Links::LinkConsumer.create(
            deployment: deployment_model,
            instance_group: 'ig1',
            name: 'c1',
            type: 'job'
          )
        end

        let(:metadata) do
          {'explicit_link' => false}
        end

        before do
          Bosh::Director::Models::Links::LinkConsumerIntent.create(
            link_consumer: consumer,
            original_name: 'ci1',
            type: 'foo',
            metadata: metadata.to_json
          )
        end

        context 'and the provider exists' do
          before do
            provider = Bosh::Director::Models::Links::LinkProvider.create(
              deployment: deployment_model,
              instance_group: 'ig1',
              name: 'p1',
              type: 'job'
            )

            Bosh::Director::Models::Links::LinkProviderIntent.create(
              link_provider: provider,
              original_name: 'pi1',
              name: 'provider_alias',
              type: 'foo'
            )
          end

          it 'does not create a link' do
            expect(deployment_model.link_consumers.count).to be > 0
            subject.resolve_deployment_links(deployment_model, options)
            expect(Bosh::Director::Models::Links::Link.count).to eq(0)
          end
        end

        context 'and the provider does NOT exist' do
          it 'raises an error' do
            expect {
              expect(deployment_model.link_consumers.count).to be > 0
              subject.resolve_deployment_links(deployment_model, options)
            }.to raise_error("Failed to resolve links from deployment 'test_deployment'. See errors below:\n  - Can't resolve link 'ci1' with type 'foo' for job  'c1' in instance_group 'ig1' in deployment 'test_deployment'")
          end

          context 'when link consumer intent is optional' do
            before do
              link_consumer_intent = Bosh::Director::Models::Links::LinkConsumerIntent.find(
                link_consumer: consumer,
                original_name: 'ci1',
                type: 'foo'
              )

              link_consumer_intent.optional = true
              link_consumer_intent.save
            end

            it 'should NOT raise an error' do
              expect(consumer.find_intent_by_name('ci1').optional).to eq(true)

              expect {
                subject.resolve_deployment_links(deployment_model, options)
              }.to_not raise_error

              expect(Bosh::Director::Models::Links::Link.count).to eq(0)
            end
          end
        end

        context 'and the providers are ambiguous' do
          before do
            provider = Bosh::Director::Models::Links::LinkProvider.create(
              deployment: deployment_model,
              instance_group: 'ig1',
              name: 'p1',
              type: 'job'
            )

            Bosh::Director::Models::Links::LinkProviderIntent.create(
              link_provider: provider,
              original_name: 'pi1',
              name: 'provider_alias',
              type: 'foo'
            )

            Bosh::Director::Models::Links::LinkProviderIntent.create(
              link_provider: provider,
              original_name: 'pi2',
              name: 'provider_alias2',
              type: 'foo'
            )
          end

          it 'raises an error' do
            expect {
              expect(deployment_model.link_consumers.count).to be > 0
              subject.resolve_deployment_links(deployment_model, options)
            }.to raise_error("Failed to resolve links from deployment 'test_deployment'. See errors below:\n  - Multiple providers of type 'foo' found for consumer link 'ci1' in job 'c1' in instance group 'ig1'. All of these match:
   Deployment: test_deployment, instance group: ig1, job: p1, link name/alias: provider_alias
   Deployment: test_deployment, instance group: ig1, job: p1, link name/alias: provider_alias2")
          end

          context 'when link consumer intent is optional' do
            before do
              link_consumer_intent = Bosh::Director::Models::Links::LinkConsumerIntent.find(
                link_consumer: consumer,
                original_name: 'ci1',
                type: 'foo'
              )

              link_consumer_intent.optional = true
              link_consumer_intent.save
            end

            it 'should raise an error' do
              expect(consumer.find_intent_by_name('ci1').optional).to eq(true)

              expect {
                subject.resolve_deployment_links(deployment_model, options)
              }.to raise_error("Failed to resolve links from deployment 'test_deployment'. See errors below:\n  - Multiple providers of type 'foo' found for consumer link 'ci1' in job 'c1' in instance group 'ig1'. All of these match:
   Deployment: test_deployment, instance group: ig1, job: p1, link name/alias: provider_alias
   Deployment: test_deployment, instance group: ig1, job: p1, link name/alias: provider_alias2")

              expect(Bosh::Director::Models::Links::Link.count).to eq(0)
            end
          end
        end
      end

      context 'when it is a manual link' do
        let(:consumer) do
          Bosh::Director::Models::Links::LinkConsumer.create(
            deployment: deployment_model,
            instance_group: 'ig1',
            name: 'c1',
            type: 'job'
          )
        end

        let(:metadata) do
          {'explicit_link' => false}
        end

        before do
          Bosh::Director::Models::Links::LinkConsumerIntent.create(
            link_consumer: consumer,
            original_name: 'ci1',
            type: 'foo',
            metadata: metadata.to_json
          )

          provider = Bosh::Director::Models::Links::LinkProvider.create(
            deployment: deployment_model,
            instance_group: 'ig1',
            name: 'c1',
            type: 'manual'
          )

          Bosh::Director::Models::Links::LinkProviderIntent.create(
            link_provider: provider,
            original_name: 'ci1',
            type: 'foo'
          )
        end

        it 'does not create a link' do
          expect(deployment_model.link_consumers.count).to be > 0
          subject.resolve_deployment_links(deployment_model, options)
          expect(Bosh::Director::Models::Links::Link.count).to eq(0)
        end
      end
    end

    context 'when dry_run flag is false' do
      let(:dry_run) {false}

      context 'when it is an explicit consumer' do
        let(:consumer) do
          Bosh::Director::Models::Links::LinkConsumer.create(
            deployment: deployment_model,
            name: 'c1',
            type: 'job',
            instance_group: 'ig1'
          )
        end

        let(:metadata) do
          {
            'explicit_link' => true
          }
        end

        before do
          Bosh::Director::Models::Links::LinkConsumerIntent.create(
            link_consumer: consumer,
            original_name: 'ci1',
            name: 'provider_alias',
            type: 'foo',
            metadata: metadata.to_json
          )
        end

        context 'and a provider exists' do
          let!(:provider) do
            Bosh::Director::Models::Links::LinkProvider.create(
              deployment: deployment_model,
              name: 'p1',
              type: 'job',
              instance_group: 'ig1'
            )
          end

          context 'and the provider intent has matching "type" and "name"' do
            before do
              Bosh::Director::Models::Links::LinkProviderIntent.create(
                link_provider: provider,
                original_name: 'pi1',
                name: 'provider_alias',
                type: 'foo',
                content: {default_network: 'netb', instances: [{dns_addresses: {neta: 'dns1', netb: 'dns2'}, addresses: {neta: 'ip1', netb: 'ip2'}}]}.to_json
              )
            end

            it 'creates a link' do
              expect(deployment_model.link_consumers.count).to be > 0
              subject.resolve_deployment_links(deployment_model, options)
              expect(Bosh::Director::Models::Links::Link.count).to eq(1)
              expect(Bosh::Director::Models::Links::Link.first.link_content).to eq({default_network: 'netb', instances: [{address: 'dns2'}]}.to_json)
            end
          end

          context 'and the provider intent has matching "type" but not "name"' do
            before do
              Bosh::Director::Models::Links::LinkProviderIntent.create(
                link_provider: provider,
                original_name: 'pi1',
                name: 'non-matching-alias',
                type: 'foo',
                content: {default_network: 'netb', instances: [{dns_addresses: {neta: 'dns1', netb: 'dns2'}, addresses: {neta: 'ip1', netb: 'ip2'}}]}.to_json
              )
            end

            it 'should raise an error' do
              expect {
                subject.resolve_deployment_links(deployment_model, options)
              }.to raise_error("Failed to resolve links from deployment 'test_deployment'. See errors below:\n  - Can't resolve link 'provider_alias' for job 'c1' in instance group 'ig1' in deployment 'test_deployment'")
            end
          end
        end

        context 'and a provider does NOT exist' do
          it 'raises an error' do
            expect(deployment_model.link_consumers.count).to be > 0

            expect {
              subject.resolve_deployment_links(deployment_model, options)
            }.to raise_error("Failed to resolve links from deployment 'test_deployment'. See errors below:\n  - Can't resolve link 'provider_alias' for job 'c1' in instance group 'ig1' in deployment 'test_deployment'")
          end
        end

        context 'and the providers are ambiguous' do
          before do
            provider = Bosh::Director::Models::Links::LinkProvider.create(
              deployment: deployment_model,
              name: 'p1',
              type: 'job',
              instance_group: 'ig1'
            )

            Bosh::Director::Models::Links::LinkProviderIntent.create(
              link_provider: provider,
              original_name: 'pi1',
              name: 'provider_alias',
              type: 'foo'
            )

            Bosh::Director::Models::Links::LinkProviderIntent.create(
              link_provider: provider,
              original_name: 'pi2',
              name: 'provider_alias',
              type: 'foo'
            )
          end

          it 'raises an error' do
            expect(deployment_model.link_consumers.count).to be > 0

            expect {
              subject.resolve_deployment_links(deployment_model, options)
            }.to raise_error("Failed to resolve links from deployment 'test_deployment'. See errors below:\n  - Multiple providers of name/alias 'provider_alias' found for job 'c1' in instance group 'ig1'. All of these match:
   pi1 aliased as 'provider_alias' (job: p1, instance group: ig1)
   pi2 aliased as 'provider_alias' (job: p1, instance group: ig1)")
          end
        end

        context 'and requesting provider from different deployment' do
          let!(:second_deployment_model) do
            Bosh::Director::Models::Deployment.create(
              name: 'second_deployment'
            )
          end

          let(:metadata) do
            {
              'explicit_link' => true,
              'from_deployment' => 'second_deployment'
            }
          end

          context 'and the specified deployment has a matching shared provider intent' do
            before do
              provider = Bosh::Director::Models::Links::LinkProvider.create(
                deployment: second_deployment_model,
                name: 'p2',
                type: 'job',
                instance_group: 'ig2'
              )

              Bosh::Director::Models::Links::LinkProviderIntent.create(
                link_provider: provider,
                original_name: 'pi2',
                name: 'provider_alias',
                type: 'foo',
                shared: true,
                content: {default_network: 'netb', instances: [{dns_addresses: {neta: 'dns1', netb: 'dns2'}, addresses: {neta: 'ip1', netb: 'ip2'}}]}.to_json
              )
            end

            it 'should create a link' do
              expect(deployment_model.link_consumers.count).to be > 0
              subject.resolve_deployment_links(deployment_model, options)
              expect(Bosh::Director::Models::Links::Link.count).to eq(1)
              expect(Bosh::Director::Models::Links::Link.first.link_content).to eq({default_network: 'netb', instances: [{address: 'dns2'}]}.to_json)
            end
          end

          context 'and the specified deployment has a matching non-shared provider intent' do
            before do
              provider = Bosh::Director::Models::Links::LinkProvider.create(
                deployment: second_deployment_model,
                name: 'p2',
                type: 'job',
                instance_group: 'ig2'
              )

              Bosh::Director::Models::Links::LinkProviderIntent.create(
                link_provider: provider,
                original_name: 'pi2',
                name: 'provider_alias',
                type: 'foo',
                shared: false,
                content: {default_network: 'netb', instances: [{dns_addresses: {neta: 'dns1', netb: 'dns2'}, addresses: {neta: 'ip1', netb: 'ip2'}}]}.to_json
              )
            end

            it 'should raise an error' do
              expect(deployment_model.link_consumers.count).to be > 0

              expect {
                subject.resolve_deployment_links(deployment_model, options)
              }.to raise_error("Failed to resolve links from deployment 'test_deployment'. See errors below:\n  - Can't resolve link 'provider_alias' for job 'c1' in instance group 'ig1' in deployment 'test_deployment'")
            end
          end

          context 'and the specified deployment has no providers' do
            it 'should raise an error' do
              expect(deployment_model.link_consumers.count).to be > 0

              expect {
                subject.resolve_deployment_links(deployment_model, options)
              }.to raise_error("Failed to resolve links from deployment 'test_deployment'. See errors below:\n  - Can't resolve link 'provider_alias' for job 'c1' in instance group 'ig1' in deployment 'test_deployment'")
            end
          end

          context 'and the specified deployment is not found' do
            let(:metadata) do
              {
                'explicit_link' => true,
                'from_deployment' => 'not_found_deployment'
              }
            end

            it 'raises an error' do
              expect {
                subject.resolve_deployment_links(deployment_model, options)
              }.to raise_error("Failed to resolve links from deployment 'test_deployment'. See errors below:\n  - Can't find deployment 'not_found_deployment'")
            end
          end
        end

        context 'and requesting for ip addresses only' do
          let(:metadata) do
            {
              'explicit_link' => true,
              'ip_addresses' => true,
            }
          end

          let(:provider_intent_content) do
            {
              default_network: 'netb',
              networks: ['neta', 'netb'],
              instances: [
                {
                  dns_addresses: {neta: 'dns1', netb: 'dns2'},
                  addresses: {neta: 'ip1', netb: 'ip2'}
                }
              ]
            }
          end

          before do
            provider = Bosh::Director::Models::Links::LinkProvider.create(
              deployment: deployment_model,
              name: 'p1',
              type: 'job',
              instance_group: 'ig1'
            )

            Bosh::Director::Models::Links::LinkProviderIntent.create(
              link_provider: provider,
              original_name: 'pi1',
              name: 'provider_alias',
              type: 'foo',
              content: provider_intent_content.to_json
            )
          end

          it 'creates a link where "address" is an IP address' do
            expect(deployment_model.link_consumers.count).to be > 0

            expected_hash = {
              'default_network' => 'netb',
              'networks' => ['neta', 'netb'],
              'instances' => [{'address' => 'ip2'}]
            }

            subject.resolve_deployment_links(deployment_model, options)
            links = Bosh::Director::Models::Links::Link.all
            expect(links.size).to eq(1)
            expect(JSON.parse(links.first.link_content)).to eq(expected_hash)
          end

          context 'and "default_network" is not defined in the provider content' do
            let(:provider_intent_content) do
              {
                networks: ['neta', 'netb'],
                instances: [{dns_addresses: {neta: 'dns1', netb: 'dns2'}, addresses: {neta: 'ip1', netb: 'ip2'}}]
              }
            end

            it 'should raise an error' do
              expect {
                subject.resolve_deployment_links(deployment_model, options)
              }.to raise_error("Failed to resolve links from deployment 'test_deployment'. See errors below:\n  - Unable to retrieve default network from provider. Please redeploy provider deployment")
            end
          end

          context 'and requesting a specific network' do
            let(:metadata) do
              {
                'explicit_link' => true,
                'ip_addresses' => true,
                'network' => 'neta'
              }
            end

            context 'and the provider intent has the requested network' do
              it 'creates a link where "address" is from the specified network' do
                expect(deployment_model.link_consumers.count).to be > 0

                subject.resolve_deployment_links(deployment_model, options)
                links = Bosh::Director::Models::Links::Link.all
                expect(links.size).to eq(1)
                expect(JSON.parse(links.first.link_content)).to match({'default_network' => String, 'networks' => ['neta', 'netb'], 'instances' => [{'address' => 'ip1'}]})
              end

              context 'and an instance in the provider does not contain the preferred network' do
                let(:provider_intent_content) do
                  {
                    default_network: 'netb',
                    networks: ['neta', 'netb'],
                    instances: [
                      {dns_addresses: {netb: 'dns2'}, addresses: {netb: 'ip2'}}
                    ]
                  }
                end

                it 'should raise an error' do
                  expect {
                    subject.resolve_deployment_links(deployment_model, options)
                  }.to raise_error("Failed to resolve links from deployment 'test_deployment'. See errors below:\n  - Provider link does not have network: 'neta'")
                end
              end
            end

            context 'and the provider intent does not have the requested network' do
              let(:provider_intent_content) do
                {
                  default_network: 'netb',
                  networks: ['netb'],
                  instances: [
                    {
                      dns_addresses: {neta: 'dns1', netb: 'dns2'},
                      addresses: {neta: 'ip1', netb: 'ip2'}
                    }
                  ]
                }
              end

              it 'raises an error' do
                expect {
                  subject.resolve_deployment_links(deployment_model, options)
                }.to raise_error("Failed to resolve links from deployment 'test_deployment'. See errors below:\n  - Can't resolve link 'provider_alias' in instance group 'ig1' on job 'c1' in deployment 'test_deployment' with network 'neta'")
              end
            end
          end
        end

        context 'and requesting for DNS entries' do
          let(:metadata) do
            {
              'explicit_link' => true,
              'ip_addresses' => false,
            }
          end

          let(:provider_intent_content) do
            {
              default_network: 'netb',
              networks: ['neta', 'netb'],
              instances: [{dns_addresses: {neta: 'dns1', netb: 'dns2'}, addresses: {neta: 'ip1', netb: 'ip2'}}]}
          end

          before do
            provider = Bosh::Director::Models::Links::LinkProvider.create(
              deployment: deployment_model,
              name: 'p1',
              type: 'job',
              instance_group: 'ig1'
            )

            Bosh::Director::Models::Links::LinkProviderIntent.create(
              link_provider: provider,
              original_name: 'pi1',
              name: 'provider_alias',
              type: 'foo',
              content: provider_intent_content.to_json
            )
          end

          it 'creates a link where "address" is a DNS entry' do
            expect(deployment_model.link_consumers.count).to be > 0
            subject.resolve_deployment_links(deployment_model, options)

            links = Bosh::Director::Models::Links::Link.all
            expect(links.size).to eq(1)
            expect(JSON.parse(links.first.link_content)).to eq({'default_network' => 'netb', 'networks' => ['neta', 'netb'], 'instances' => [{'address' => 'dns2'}]})
          end

          context 'and "default_network" is not defined in the provider content' do
            let(:provider_intent_content) do
              {
                networks: ['neta', 'netb'],
                instances: [{dns_addresses: {neta: 'dns1', netb: 'dns2'}, addresses: {neta: 'ip1', netb: 'ip2'}}]
              }
            end

            it 'should raise an error' do
              expect {
                subject.resolve_deployment_links(deployment_model, options)
              }.to raise_error("Failed to resolve links from deployment 'test_deployment'. See errors below:\n  - Unable to retrieve default network from provider. Please redeploy provider deployment")
            end
          end

          context 'and requesting a specific network' do
            let(:metadata) do
              {
                'explicit_link' => true,
                'ip_addresses' => false,
                'network' => 'neta'
              }
            end

            context 'and the provider intent has the requested network' do
              it 'creates a link where "address" is from the specified network' do
                expect(deployment_model.link_consumers.count).to be > 0

                subject.resolve_deployment_links(deployment_model, options)
                links = Bosh::Director::Models::Links::Link.all
                expect(links.size).to eq(1)
                expect(JSON.parse(links.first.link_content)).to match({'default_network' => String, 'networks' => ['neta', 'netb'], 'instances' => [{'address' => 'dns1'}]})
              end

              context 'and an instance in the provider does not contain the preferred network' do
                let(:provider_intent_content) do
                  {
                    default_network: 'netb',
                    networks: ['neta', 'netb'],
                    instances: [
                      {dns_addresses: {netb: 'dns2'}, addresses: {netb: 'ip2'}}
                    ]
                  }
                end

                it 'should raise an error' do
                  expect {
                    subject.resolve_deployment_links(deployment_model, options)
                  }.to raise_error("Failed to resolve links from deployment 'test_deployment'. See errors below:\n  - Provider link does not have network: 'neta'")
                end
              end
            end

            context 'and the provider intent does not have the requested network' do
              let(:provider_intent_content) do
                {
                  default_network: 'netb',
                  networks: ['netb'],
                  instances: [
                    {
                      dns_addresses: {neta: 'dns1', netb: 'dns2'},
                      addresses: {neta: 'ip1', netb: 'ip2'}
                    }
                  ]
                }
              end

              it 'raises an error' do
                expect {
                  subject.resolve_deployment_links(deployment_model, options)
                }.to raise_error("Failed to resolve links from deployment 'test_deployment'. See errors below:\n  - Can't resolve link 'provider_alias' in instance group 'ig1' on job 'c1' in deployment 'test_deployment' with network 'neta'")
              end
            end
          end
        end

        context 'and ip_addresses is not defined in the consumer options in the manifest' do
          let(:metadata) do
            {
              'explicit_link' => true,
              'ip_addresses' => nil,
            }
          end
          let(:provider_intent_content) do
            {default_network: 'netb', instances: [{dns_addresses: {neta: 'dns1', netb: 'dns2'}, addresses: {neta: 'ip1', netb: 'ip2'}}]}
          end

          before do
            provider = Bosh::Director::Models::Links::LinkProvider.create(
              deployment: deployment_model,
              name: 'p1',
              type: 'job',
              instance_group: 'ig1'
            )

            Bosh::Director::Models::Links::LinkProviderIntent.create(
              link_provider: provider,
              original_name: 'pi1',
              name: 'provider_alias',
              type: 'foo',
              content: provider_intent_content.to_json
            )
          end

          context 'and the global_use_dns setting is TRUE' do
            let(:global_use_dns_entry) {true}

            it 'should honor the global setting' do
              subject.resolve_deployment_links(deployment_model, options)
              links = Bosh::Director::Models::Links::Link.all
              expect(links.size).to eq(1)
              expect(JSON.parse(links.first.link_content)).to eq({'default_network' => 'netb', 'instances' => [{'address' => 'dns2'}]})
            end
          end

          context 'and the global_use_dns setting is FALSE' do
            let(:global_use_dns_entry) {false}

            it 'should honor the global setting' do
              subject.resolve_deployment_links(deployment_model, options)
              links = Bosh::Director::Models::Links::Link.all
              expect(links.size).to eq(1)
              expect(JSON.parse(links.first.link_content)).to eq({'default_network' => 'netb', 'instances' => [{'address' => 'ip2'}]})
            end
          end
        end

        context 'and requesting a specific network' do
          let(:metadata) do
            {
              explicit_link: true,
              network: 'neta'
            }
          end

          let(:provider) do
            Bosh::Director::Models::Links::LinkProvider.create(
              deployment: deployment_model,
              name: 'p1',
              type: 'job',
              instance_group: 'ig1'
            )
          end

          context 'and the provider intent has the requested network' do
            let(:link_provider_content) do
              {
                default_network: 'netb',
                networks: ['neta', 'netb'],
                instances: [
                  {dns_addresses: {neta: 'dns1', netb: 'dns2'}, addresses: {neta: 'ip1', netb: 'ip2'}}
                ]
              }
            end

            before do
              Bosh::Director::Models::Links::LinkProviderIntent.create(
                link_provider: provider,
                original_name: 'pi1',
                name: 'provider_alias',
                type: 'foo',
                content: link_provider_content.to_json
              )
            end

            it 'creates a link where "address" is from the specified network' do
              expect(deployment_model.link_consumers.count).to be > 0

              subject.resolve_deployment_links(deployment_model, options)
              links = Bosh::Director::Models::Links::Link.all
              expect(links.size).to eq(1)
              expect(JSON.parse(links.first.link_content)).to match({'default_network' => String, 'networks' => ['neta', 'netb'], 'instances' => [{'address' => 'dns1'}]})
            end

            context 'and an instance in the provider does not contain the preferred network' do
              let(:link_provider_content) do
                {
                  networks: ['neta', 'netb'],
                  instances: [
                    {dns_addresses: {netb: 'dns2'}, addresses: {netb: 'ip2'}}
                  ]
                }
              end

              it 'should raise an error' do
                expect {
                  subject.resolve_deployment_links(deployment_model, options)
                }.to raise_error("Failed to resolve links from deployment 'test_deployment'. See errors below:\n  - Provider link does not have network: 'neta'")
              end
            end
          end

          context 'and the provider intent does not have the requested network' do
            before do
              Bosh::Director::Models::Links::LinkProviderIntent.create(
                link_provider: provider,
                original_name: 'pi1',
                name: 'provider_alias',
                type: 'foo',
                content: {
                  default_network: 'netb',
                  networks: [],
                  instances: [
                    {dns_addresses: {neta: 'dns1', netb: 'dns2'}, addresses: {neta: 'ip1', netb: 'ip2'}}
                  ]}.to_json
              )
            end

            it 'raises an error' do
              expect {
                subject.resolve_deployment_links(deployment_model, options)
              }.to raise_error("Failed to resolve links from deployment 'test_deployment'. See errors below:\n  - Can't resolve link 'provider_alias' in instance group 'ig1' on job 'c1' in deployment 'test_deployment' with network 'neta'")
            end
          end
        end
      end

      context 'when it is an implicit consumer' do
        let(:consumer) do
          Bosh::Director::Models::Links::LinkConsumer.create(
            deployment: deployment_model,
            name: 'c1',
            type: 'job',
            instance_group: 'ig1'
          )
        end

        before do
          Bosh::Director::Models::Links::LinkConsumerIntent.create(
            link_consumer: consumer,
            original_name: 'ci1',
            type: 'foo',
            metadata: {explicit_link: false}.to_json
          )
        end

        context 'and the provider exists' do
          let(:provider) do
            Bosh::Director::Models::Links::LinkProvider.create(
              deployment: deployment_model,
              name: 'p1',
              type: 'job',
              instance_group: 'ig1'
            )
          end

          context 'and the provider intent has matching "type"' do
            before do
              Bosh::Director::Models::Links::LinkProviderIntent.create(
                link_provider: provider,
                original_name: 'pi1',
                name: 'provider_alias',
                type: 'foo',
                content: {default_network: 'netb', instances: [{dns_addresses: {neta: 'dns1', netb: 'dns2'}, addresses: {neta: 'ip1', netb: 'ip2'}}]}.to_json
              )
            end

            it 'creates a link' do
              expect(deployment_model.link_consumers.count).to be > 0

              subject.resolve_deployment_links(deployment_model, options)
              expect(Bosh::Director::Models::Links::Link.count).to eq(1)
              expect(Bosh::Director::Models::Links::Link.first.link_content).to eq({default_network: 'netb', instances: [{address: 'dns2'}]}.to_json)
            end
          end

          context 'and the provider intent has non-matching "type"' do
            before do
              Bosh::Director::Models::Links::LinkProviderIntent.create(
                link_provider: provider,
                original_name: 'ci1',
                name: 'ci1',
                type: 'non-matching-type',
                content: {default_network: 'netb', instances: [{dns_addresses: {neta: 'dns1', netb: 'dns2'}, addresses: {neta: 'ip1', netb: 'ip2'}}]}.to_json
              )
            end

            it 'should raise an error' do
              expect {
                subject.resolve_deployment_links(deployment_model, options)
              }.to raise_error("Failed to resolve links from deployment 'test_deployment'. See errors below:\n  - Can't resolve link 'ci1' with type 'foo' for job  'c1' in instance_group 'ig1' in deployment 'test_deployment'")
            end
          end
        end

        context 'and the provider does NOT exist' do
          it 'raises an error' do
            expect(deployment_model.link_consumers.count).to be > 0

            expect {
              subject.resolve_deployment_links(deployment_model, options)
            }.to raise_error("Failed to resolve links from deployment 'test_deployment'. See errors below:\n  - Can't resolve link 'ci1' with type 'foo' for job  'c1' in instance_group 'ig1' in deployment 'test_deployment'")
          end
        end

        context 'and the providers are ambiguous' do
          before do
            provider = Bosh::Director::Models::Links::LinkProvider.create(
              deployment: deployment_model,
              name: 'p1',
              type: 'job',
              instance_group: 'ig1'
            )

            Bosh::Director::Models::Links::LinkProviderIntent.create(
              link_provider: provider,
              original_name: 'pi1',
              name: 'provider_alias',
              type: 'foo'
            )

            Bosh::Director::Models::Links::LinkProviderIntent.create(
              link_provider: provider,
              original_name: 'pi2',
              name: 'provider_alias2',
              type: 'foo'
            )
          end

          it 'raises an error' do
            expect(deployment_model.link_consumers.count).to be > 0

            expect {
              subject.resolve_deployment_links(deployment_model, options)
            }.to raise_error("Failed to resolve links from deployment 'test_deployment'. See errors below:\n  - Multiple providers of type 'foo' found for consumer link 'ci1' in job 'c1' in instance group 'ig1'. All of these match:
   Deployment: test_deployment, instance group: ig1, job: p1, link name/alias: provider_alias
   Deployment: test_deployment, instance group: ig1, job: p1, link name/alias: provider_alias2")
          end
        end
      end

      context 'when it is a manual link' do
        let(:consumer) do
          Bosh::Director::Models::Links::LinkConsumer.create(
            deployment: deployment_model,
            instance_group: 'ig1',
            name: 'c1',
            type: 'job'
          )
        end

        let(:metadata) do
          {
            explicit_link: true,
            manual_link: true
          }
        end

        let(:manual_link_contents) do
          {
            :deployment_name => 'meow-deployment',
            :properties => {
              :port => 6
            },
            :instances => ['a', 'b']
          }
        end

        before do
          Bosh::Director::Models::Links::LinkConsumerIntent.create(
            link_consumer: consumer,
            original_name: 'ci1',
            type: 'foo',
            metadata: metadata.to_json
          )
        end

        context 'when there is no manual link provider' do
          it 'should raise an error' do
            expect(deployment_model.link_consumers.count).to be > 0

            expect {
              subject.resolve_deployment_links(deployment_model, options)
            }.to raise_error "Failed to resolve links from deployment 'test_deployment'. See errors below:\n  - Failed to find manual link provider for consumer 'ci1' in job 'c1' in instance group 'ci1'"
          end
        end

        context 'when there is a manual link provider' do
          let!(:manual_link_provider) do
            Bosh::Director::Models::Links::LinkProvider.create(
              deployment: deployment_model,
              instance_group: 'ig1',
              name: 'c1',
              type: 'manual'
            )
          end

          it 'should raise an error when there is no satisfying provider intent' do
            expect(deployment_model.link_consumers.count).to be > 0

            expect {
              subject.resolve_deployment_links(deployment_model, options)
            }.to raise_error "Failed to resolve links from deployment 'test_deployment'. See errors below:\n  - Failed to find manual link provider for consumer 'ci1' in job 'c1' in instance group 'ci1'"
          end

          context 'when there is a manual link provider intent that satisfies the manual consumer' do
            before do
              Bosh::Director::Models::Links::LinkProviderIntent.create(
                link_provider: manual_link_provider,
                original_name: 'ci1',
                type: 'foo',
                content: manual_link_contents.to_json
              )
            end

            it 'creates a link' do
              expect(deployment_model.link_consumers.count).to be > 0
              subject.resolve_deployment_links(deployment_model, options)

              links_created = Bosh::Director::Models::Links::Link.all

              expect(links_created.size).to eq(1)
              expect(links_created.first.link_content).to eq(manual_link_contents.to_json)
            end
          end
        end
      end
    end
  end

  describe '#bind_links_to_instance' do
    let(:instance_model) do
      Bosh::Director::Models::Instance.make(deployment: deployment_model)
    end

    let(:instance) do
      instance_double(Bosh::Director::DeploymentPlan::Instance).tap do |mock|
        allow(mock).to receive(:instance_group_name).and_return('instance-group-name')
        allow(mock).to receive(:deployment_model).and_return(deployment_model)
        allow(mock).to receive(:model).and_return(instance_model)
      end
    end

    context 'when an instance does not use links' do
      it 'should not create an association between any links to the instance' do
        subject.bind_links_to_instance(instance)

        expect(instance_model.links).to be_empty
      end
    end

    context 'when an instance uses links' do
      before do
        # Create consumer
        consumer = Bosh::Director::Models::Links::LinkConsumer.create(
          deployment: deployment_model,
          instance_group: 'instance-group-name',
          name: 'job-1',
          type: 'job'
        )

        consumer_intent = Bosh::Director::Models::Links::LinkConsumerIntent.create(
          link_consumer: consumer,
          original_name: 'foo',
          type: 'bar',
          name: 'foo-alias'
        )

        Bosh::Director::Models::Links::Link.create(
          link_consumer_intent: consumer_intent,
          name: 'foo',
          link_content: '{}'
        )
      end

      it 'should create an association between the instance and the links' do
        subject.bind_links_to_instance(instance)
        expect(instance_model.links.size).to eq(1)
      end
    end
  end

  describe '#get_links_for_instance_group' do
    let(:instance_group_name) {'instance-group-name'}

    context 'when an instance does not use links' do
      it 'returns an empty hash' do
        links = subject.get_links_for_instance_group(deployment_model,instance_group_name)

        expect(links).to be_empty
      end
    end

    context 'when an instance uses links' do
      before do
        # Create consumer
        control_consumer = Bosh::Director::Models::Links::LinkConsumer.create(
          deployment: deployment_model,
          instance_group: 'control-instance-group-name',
          name: 'control-job-1',
          type: 'job'
        )

        control_consumer_intent = Bosh::Director::Models::Links::LinkConsumerIntent.create(
          link_consumer: control_consumer,
          original_name: 'control-foo',
          type: 'control-bar',
          name: 'control-foo-alias'
        )

        Bosh::Director::Models::Links::Link.create(
          link_consumer_intent: control_consumer_intent,
          name: 'control-foo',
          link_content: '{}'
        )

        consumer = Bosh::Director::Models::Links::LinkConsumer.create(
          deployment: deployment_model,
          instance_group: 'instance-group-name',
          name: 'job-1',
          type: 'job'
        )

        consumer_intent_1 = Bosh::Director::Models::Links::LinkConsumerIntent.create(
          link_consumer: consumer,
          original_name: 'foo',
          type: 'bar',
          name: 'foo-alias'
        )

        Bosh::Director::Models::Links::Link.create(
          link_consumer_intent: consumer_intent_1,
          name: 'foo',
          link_content: '{"properties": {"fizz": "buzz"}}'
        )

        consumer_intent_2 = Bosh::Director::Models::Links::LinkConsumerIntent.create(
          link_consumer: consumer,
          original_name: 'meow',
          type: 'bar',
          name: 'meow-alias'
        )

        Bosh::Director::Models::Links::Link.create(
          link_consumer_intent: consumer_intent_2,
          name: 'meow',
          link_content: '{"properties": {"snoopy": "dog"}}'
        )
      end

      it 'should return the links associated with the instance groups namespaced by job name' do
        links = subject.get_links_for_instance_group(deployment_model, instance_group_name)
        expect(links.size).to eq(1)
        expect(links['job-1'].size).to eq(2)

        expect(links['job-1']['foo']).to eq({'properties' => {'fizz' => 'buzz'}})
        expect(links['job-1']['meow']).to eq({'properties' => {'snoopy' => 'dog'}})
      end
    end
  end

  describe '#get_links_from_deployment' do
    before do
      consumer = Bosh::Director::Models::Links::LinkConsumer.create(
        deployment: deployment_model,
        instance_group: 'ig1',
        name: 'c1',
        type: 'job'
      )

      consumer_intent = Bosh::Director::Models::Links::LinkConsumerIntent.create(
        link_consumer: consumer,
        original_name: 'ci1',
        type: 'foo',
        metadata: {explicit_link: true}.to_json
      )

      provider = Bosh::Director::Models::Links::LinkProvider.create(
        deployment: deployment_model,
        instance_group: 'ig1',
        name: 'c1',
        type: 'manual'
      )

      provider_intent = Bosh::Director::Models::Links::LinkProviderIntent.create(
        link_provider: provider,
        original_name: 'ci1',
        type: 'foo'
      )

      Bosh::Director::Models::Links::Link.create(
        link_provider_intent: provider_intent,
        link_consumer_intent: consumer_intent,
        name: consumer_intent.original_name,
        link_content: '{"foo": "bar"}'
      )
    end

    it 'should return a JSON string with the links encoded within it.' do
      result = subject.get_links_from_deployment(deployment_model)
      expected_result = {
        "c1" => {
          "ci1" => {
            "foo" => "bar"
          }
        }
      }
      expect(result).to match(expected_result)
    end
  end

  describe '#update_provider_intents_contents' do
    let(:deployment_model) {BD::Models::Deployment.make}
    let(:link_providers) {[]}
    let(:deployment_plan) {instance_double(Bosh::Director::DeploymentPlan::Planner)}

    context 'when the provider type is a job' do
      let(:provider_1) do
        Bosh::Director::Models::Links::LinkProvider.make(
          deployment: deployment_model,
          instance_group: 'foo-ig',
          name: 'foo-provider',
          type: 'job'
        )
      end

      let(:provider_1_intent_1) do
        Bosh::Director::Models::Links::LinkProviderIntent.make(
          :link_provider => provider_1,
          :original_name => 'link_original_name_1',
          :name => 'link_name_1',
          :type => 'link_type_1',
          :shared => true,
          :consumable => true,
          :content => '{}',
          :metadata => {'mapped_properties' => {'a' => '1'}}.to_json
        )
      end

      let(:provider_1_intent_2) do
        Bosh::Director::Models::Links::LinkProviderIntent.make(
          :link_provider => provider_1,
          :original_name => 'link_original_name_2',
          :name => 'link_name_2',
          :type => 'link_type_2',
          :shared => true,
          :consumable => true,
          :content => '{}',
          :metadata => {'mapped_properties' => {'b' => '2'}}.to_json
        )
      end

      let(:provider_2) do
        Bosh::Director::Models::Links::LinkProvider.make(
          deployment: deployment_model,
          instance_group: 'foo-ig',
          name: 'foo-provider-2',
          type: 'job'
        )
      end

      let(:provider_2_intent_1) do
        Bosh::Director::Models::Links::LinkProviderIntent.make(
          :link_provider => provider_2,
          :original_name => 'link_original_name_3',
          :name => 'link_name_3',
          :type => 'link_type_3',
          :shared => true,
          :consumable => true,
          :content => '{}',
          :metadata => {'mapped_properties' => {'c' => '1'}}.to_json
        )
      end

      let(:provider_2_intent_2) do
        Bosh::Director::Models::Links::LinkProviderIntent.make(
          :link_provider => provider_2,
          :original_name => 'link_original_name_4',
          :name => 'link_name_4',
          :type => 'link_type_4',
          :shared => true,
          :consumable => true,
          :content => '{}',
          :metadata => {'mapped_properties' => {'d' => '2'}}.to_json
        )
      end

      let(:link_providers) do
        [provider_1, provider_2]
      end

      let(:instance_group) do
        instance_double(Bosh::Director::DeploymentPlan::InstanceGroup)
      end

      let(:link_1) do
        instance_double(Bosh::Director::DeploymentPlan::Link)
      end

      let(:link_2) do
        instance_double(Bosh::Director::DeploymentPlan::Link)
      end

      let(:link_3) do
        instance_double(Bosh::Director::DeploymentPlan::Link)
      end

      let(:link_4) do
        instance_double(Bosh::Director::DeploymentPlan::Link)
      end

      before do
        allow(provider_1).to receive(:intents).and_return([provider_1_intent_1, provider_1_intent_2])
        allow(provider_2).to receive(:intents).and_return([provider_2_intent_1, provider_2_intent_2])
        allow(deployment_model).to receive(:link_providers).and_return(link_providers)

        allow(link_1).to receive_message_chain(:spec, :to_json).and_return("{'foo_1':'bar_1'}")
        allow(link_2).to receive_message_chain(:spec, :to_json).and_return("{'foo_2':'bar_2'}")
        allow(link_3).to receive_message_chain(:spec, :to_json).and_return("{'foo_3':'bar_3'}")
        allow(link_4).to receive_message_chain(:spec, :to_json).and_return("{'foo_4':'bar_4'}")
        allow(deployment_plan).to receive(:instance_group).and_return(instance_group)
      end

      it 'updates the contents field of the provider intents' do
        expect(Bosh::Director::DeploymentPlan::Link).to receive(:new).with(deployment_model.name, instance_group, {'a' => '1'}).and_return(link_1)
        expect(Bosh::Director::DeploymentPlan::Link).to receive(:new).with(deployment_model.name, instance_group, {'b' => '2'}).and_return(link_2)
        expect(Bosh::Director::DeploymentPlan::Link).to receive(:new).with(deployment_model.name, instance_group, {'c' => '1'}).and_return(link_3)
        expect(Bosh::Director::DeploymentPlan::Link).to receive(:new).with(deployment_model.name, instance_group, {'d' => '2'}).and_return(link_4)

        expect(provider_1_intent_1).to receive(:save)
        expect(provider_1_intent_2).to receive(:save)
        expect(provider_2_intent_1).to receive(:save)
        expect(provider_2_intent_2).to receive(:save)

        subject.update_provider_intents_contents(link_providers, deployment_plan)

        expect(provider_1_intent_1.content).to eq("{'foo_1':'bar_1'}")
        expect(provider_1_intent_2.content).to eq("{'foo_2':'bar_2'}")
        expect(provider_2_intent_1.content).to eq("{'foo_3':'bar_3'}")
        expect(provider_2_intent_2.content).to eq("{'foo_4':'bar_4'}")
      end
    end

    shared_examples_for 'non-job providers' do
      before do
        allow(provider).to receive(:intents).and_return([provider_intent])
        allow(deployment_model).to receive(:link_providers).and_return(link_providers)
        allow(deployment_plan).to receive(:model).and_return(deployment_model)
      end

      let(:provider) do
        Bosh::Director::Models::Links::LinkProvider.make(
          deployment: deployment_model,
          instance_group: 'ig',
          name: 'some-provider',
          type: provider_type
        )
      end

      let(:provider_intent) do
        Bosh::Director::Models::Links::LinkProviderIntent.make(
          :link_provider => provider,
          :original_name => 'link_original_name_1',
          :name => 'link_name_1',
          :type => 'link_type_1',
          :shared => true,
          :consumable => true,
          :content => 'some link content'
        )
      end

      let(:link_providers) do
        [provider]
      end

      it 'does not modify the contents field of the provider intents' do
        expect(provider_intent).to_not receive(:save)

        subject.update_provider_intents_contents(link_providers, deployment_plan)
        expect(provider_intent.content).to eq('some link content')
      end
    end

    context 'when the provider type is manual' do
      let(:provider_type) {'manual'}

      it_behaves_like 'non-job providers'
    end

    context 'when the provider type is manual' do
      let(:provider_type) {'disk'}

      it_behaves_like 'non-job providers'
    end

    context 'when the provider type is somthing else' do
      let(:provider_type) {'meow'}

      it_behaves_like 'non-job providers'
    end
  end
end