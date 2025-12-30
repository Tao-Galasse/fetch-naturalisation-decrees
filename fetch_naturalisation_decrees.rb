# frozen_string_literal: true

# Script pour récupérer les PDFs publiés au Journal Officiel des naturalisations françaises via l'API Légifrance (PISTE)
# et envoyer une notification Discord avec les URLs trouvées (si configuré).

ENV['DISCORDRB_NONACL'] = '1' # Pour supprimer un warning de la gem discordrb

require 'bundler/setup'
require 'discordrb'
require_relative 'legifrance_client'

# Initialisation des credentials
client_id = ENV['LEGIFRANCE_CLIENT_ID']
client_secret = ENV['LEGIFRANCE_CLIENT_SECRET']

# Initialisation du client et authentification
client = LegifranceClient.new(
  client_id: client_id,
  client_secret: client_secret
)
client.authenticate

# Recherche des décrets de naturalisation
results = client.search_naturalisation_decrees['results']

puts "\n📄 Résultats de recherche: #{results.length} décret(s) trouvé(s)"

urls = results.map do |result|
  text_cid = result['titles'][0]['cid']
  pdf_url = client.get_pdf_url(text_cid)
  puts "   URL: #{pdf_url}"
  pdf_url
end

# Si au moins une url a été trouvée, on l'envoie dans un salon dédié sur Discord (si configuré).
return unless ENV['DISCORD_TOKEN'] && ENV['DISCORD_CHANNEL_ID']

discord_bot = Discordrb::Bot.new(token: ENV['DISCORD_TOKEN'])
discord_bot.send_message(
  ENV['DISCORD_CHANNEL_ID'],
  "Nouveaux décrets publiés :\n  #{urls.join("\n  ")}",
  false
)
