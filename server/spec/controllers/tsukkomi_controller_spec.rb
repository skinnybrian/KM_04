require 'rails_helper'

RSpec.describe TsukkomiController, type: :controller do

  describe "GET #tsukkomi_all" do
    it "returns http success" do
      get :tsukkomi_all
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #analysis" do
    it "returns http success" do
      get :analysis
      expect(response).to have_http_status(:success)
    end
  end

end
