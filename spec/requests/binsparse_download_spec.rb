# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Binsparse downloads', type: :request do
  it 'redirects to the generated Binsparse file layout' do
    get '/BSP/HB/jagmesh7.bsp.h5'

    expect(response).to have_http_status(:moved_permanently)
    expect(response).to redirect_to(
      'http://sparse-files.engr.tamu.edu/BSP/HB/jagmesh7.bsp.h5'
    )
  end
end
