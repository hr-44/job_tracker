require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe '#interpolate_link' do
    it 'returns a link prepended with "http://"' do
      actual = helper.interpolate_link('foo')
      expect(actual).to eq 'http://foo'
    end
  end

  describe '#status_tag' do
    context 'if passing a truthy value' do
      it 'calls #content_tag with these options' do
        expect(helper)
          .to receive(:content_tag)
          .with(:span, 'Yes', class: 'status true')
        helper.status_tag(true)
      end
    end
    context 'if passing a falsey value' do
      it 'calls #content_tag with these options' do
        expect(helper)
          .to receive(:content_tag)
          .with(:span, 'No', class: 'status false')
        helper.status_tag(false)
      end
    end
  end

  describe '#error_messages_for' do
    before(:each) do
      allow(helper)
        .to receive(:error_messages_partial)
        .and_return('shared/error_messages')
    end
    it 'calls render with these arguments' do
      expected_args = {
        partial: 'shared/error_messages',
        locals: { curr_object: 'foo' }
      }
      expect(helper).to receive(:render).with(expected_args)
      helper.error_messages_for('foo')
    end
  end

  describe '#delete_link_opts' do
    it 'returned hash has these keys' do
      delete_link_opts = helper.delete_link_opts
      actual = delete_link_opts.keys
      expect(actual).to eq %I(method data)
    end
    it 'the :data key is a hash with a :confirm key' do
      delete_link_opts = helper.delete_link_opts
      actual = delete_link_opts[:data][:confirm]
      expect(actual).not_to be_nil
    end
  end

  describe '#error_messages_partial' do
    it 'returns path to error messages partial' do
      actual = helper.send(:error_messages_partial)
      expect(actual).to eq 'shared/error_messages'
    end
  end

  describe '#renderer_options' do
    it 'returns a hash with this key' do
      actual = helper.send(:renderer_options)
      expect(actual).to include(:with_toc_data)
    end
  end

  describe '#md_extensions' do
    it 'returns a hash with these keys' do
      actual = helper.send(:md_extensions)
      expect(actual).to include(:no_intra_emphasis,
                                :fenced_code_blocks,
                                :disable_indented_code_blocks)
    end
  end

  describe '#html_safe' do
    it 'calls #html_safe on the input' do
      input = 'foo'
      expect(input).to receive(:html_safe)
      helper.send(:html_safe, input)
    end
  end
end
