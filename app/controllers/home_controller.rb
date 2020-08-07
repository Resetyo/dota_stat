class HomeController < ApplicationController
  def index
    @heroes = heroes

    sleep 3

    last_match = HTTParty.get("https://api.opendota.com/api/explorer?sql=SELECT match_patch.patch FROM matches JOIN match_patch ON match_patch.match_id=matches.match_id ORDER BY matches.match_id desc limit 1")

    @patch = last_match['rows'][0]['patch']
  end

  def get_stats
    _heroes = heroes.group_by { |h| h[1] }
    sleep 4
    @variant_1 = get_stats_from_api(params[:radiant].values, _heroes, params[:patch])
    sleep 5
    @variant_2 = get_stats_from_api(params[:dire].values, _heroes, params[:patch])
    render :result
  end

  private

  def get_stats_from_api ids, heroes, patch
    stats = {}
    response_win = HTTParty.get("https://api.opendota.com/api/explorer?sql=SELECT COUNT(matches.match_id) as wins, player_matches.hero_id as id FROM matches JOIN player_matches ON player_matches.match_id=matches.match_id JOIN match_patch ON match_patch.match_id=matches.match_id WHERE player_matches.hero_id IN (#{ids.join(',')}) AND matches.game_mode=2 AND (( matches.radiant_win=true AND player_matches.player_slot < 128 ) OR ( matches.radiant_win=false AND player_matches.player_slot > 127 )) AND match_patch.patch='#{patch}' GROUP BY player_matches.hero_id ORDER BY player_matches.hero_id asc")
    sleep 5
    response_los = HTTParty.get("https://api.opendota.com/api/explorer?sql=SELECT COUNT(matches.match_id) as wins, player_matches.hero_id as id FROM matches JOIN player_matches ON player_matches.match_id=matches.match_id JOIN match_patch ON match_patch.match_id=matches.match_id WHERE player_matches.hero_id IN (#{ids.join(',')}) AND matches.game_mode=2 AND (( matches.radiant_win=false AND player_matches.player_slot < 128 ) OR ( matches.radiant_win=true AND player_matches.player_slot > 127 )) AND match_patch.patch='#{patch}' GROUP BY player_matches.hero_id ORDER BY player_matches.hero_id asc")

    logger.warn "============#{response_win.body}"
    logger.warn "============#{response_los.body}"

    loses = JSON.parse(response_los.body)["rows"].group_by{ |t| t["id"] }

    rates = JSON.parse(response_win.body)["rows"].map do |_hash|
      {
        rate: _hash["wins"].to_f / (_hash["wins"].to_f + loses[_hash["id"]][0]["wins"].to_f),
        hero_name: heroes[_hash['id']][0][0],
        total: _hash["wins"].to_i + loses[_hash["id"]][0]["wins"].to_i
      }
    end

  end

  def heroes

    response = HTTParty.get('https://api.opendota.com/api/heroes')

    JSON.parse(response.body).map {|h| [h['localized_name'],h['id']] }
  end
end
