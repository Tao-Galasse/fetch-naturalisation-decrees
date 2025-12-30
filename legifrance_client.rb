# frozen_string_literal: true

require 'json'
require 'rest-client'

# Client pour interagir avec l'API Légifrance (PISTE)
# Permet de s'authentifier via OAuth2 et de rechercher des décrets publiés au Journal Officiel
class LegifranceClient
  OAUTH_URL = 'https://oauth.piste.gouv.fr/api/oauth/token'
  API_BASE_URL = 'https://api.piste.gouv.fr/dila/legifrance/lf-engine-app'

  def initialize(client_id:, client_secret:)
    @client_id = client_id
    @client_secret = client_secret
    @access_token = nil
  end

  # Authentification OAuth2 (Client Credentials)
  def authenticate
    response = RestClient.post(
      OAUTH_URL,
      {
        grant_type: 'client_credentials',
        client_id: @client_id,
        client_secret: @client_secret,
        scope: 'openid'
      },
      {
        content_type: 'application/x-www-form-urlencoded',
        verify_ssl: false
      }
    )

    data = JSON.parse(response.body)
    @access_token = data['access_token']
    puts '✓ Authentification réussie'
    true
  rescue RestClient::ExceptionWithResponse => e
    puts "✗ Erreur d'authentification: #{e.response.code} - #{e.response.body}"
    false
  rescue StandardError => e
    puts "✗ Erreur d'authentification: #{e.message}"
    false
  end

  # Recherche les décrets de naturalisation dans le JORF compris entre 2 dates (par défaut, entre hier et aujourd'hui)
  def search_naturalisation_decrees(start_date: (Date.today - 1).to_s, end_date: Date.today.to_s)
    response = RestClient.post(
      "#{API_BASE_URL}/search",
      {
        recherche: {
          filtres: [
            {
              valeurs: ['DECRET'],
              facette: 'NATURE'
            },
            {
              dates: {
                start: start_date,
                end: end_date
              },
              facette: 'DATE_SIGNATURE'
            }
          ],
          champs: [
            {
              criteres: [
                {
                  valeur: 'naturalisation',
                  operateur: 'ET',
                  typeRecherche: 'UN_DES_MOTS'
                }
              ],
              operateur: 'ET',
              typeChamp: 'TITLE'
            }
          ],
          sort: 'SIGNATURE_DATE_DESC',
          pageSize: 100,
          pageNumber: 1,
          operateur: 'ET'
        },
        fond: 'JORF'
      }.to_json,
      {
        Authorization: "Bearer #{@access_token}",
        content_type: :json,
        accept: :json,
        verify_ssl: false
      }
    )
    JSON.parse(response.body)
  rescue RestClient::ExceptionWithResponse => e
    puts "✗ Erreur de recherche: #{e.response.code} - #{e.response.body}"
    nil
  rescue StandardError => e
    puts "✗ Erreur de recherche: #{e.message}"
    nil
  end

  # Récupère l'URL du PDF d'un décret
  def get_pdf_url(text_cid)
    "https://www.legifrance.gouv.fr/jorf/id/#{text_cid}"
  end
end
