# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Sparse file redirects', type: :request do
  around do |example|
    original_base_url = ENV['SPARSE_FILES_BASE_URL']
    ENV['SPARSE_FILES_BASE_URL'] = configured_base_url
    example.run
  ensure
    ENV['SPARSE_FILES_BASE_URL'] = original_base_url
    Rails.application.reload_routes!
  end

  shared_examples 'sparse file redirects' do |expected_base_url|
    before { Rails.application.reload_routes! }

    %w[/mat/Group/matrix.mat /RB/Group/matrix.tar.gz /MM/Group/matrix.tar.gz
       /svd/Group/matrix_SVD.mat /files/nested/path/data.csv].each do |path|
      it "permanently redirects #{path} to the sparse files base URL" do
        get path

        expect(response).to have_http_status(:moved_permanently)
        expect(response).to redirect_to("#{expected_base_url}#{path}")
      end
    end

    %w[/files/Group/matrix.png /files/legend.jpg].each do |path|
      it "keeps the image host for #{path}" do
        get path

        expect(response).to have_http_status(:moved_permanently)
        expect(response).to redirect_to("https://sparse-files-images.engr.tamu.edu#{path.delete_prefix('/files')}")
      end
    end
  end

  context 'when SPARSE_FILES_BASE_URL is unset' do
    let(:configured_base_url) { nil }

    it 'fails to load the routes instead of using a fallback host' do
      expect { Rails.application.reload_routes! }.to raise_error(KeyError, /SPARSE_FILES_BASE_URL/)
    end
  end

  context 'when SPARSE_FILES_BASE_URL is configured' do
    let(:configured_base_url) { 'https://downloads.example.com/archive' }

    include_examples 'sparse file redirects', 'https://downloads.example.com/archive'
  end

  context 'when SPARSE_FILES_BASE_URL has a trailing slash' do
    let(:configured_base_url) { 'https://downloads.example.com/archive/' }

    include_examples 'sparse file redirects', 'https://downloads.example.com/archive'
  end
end
