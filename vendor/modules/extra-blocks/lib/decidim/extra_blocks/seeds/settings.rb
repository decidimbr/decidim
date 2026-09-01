# frozen_string_literal: true

module Decidim
  module ExtraBlocks
    class Seeds
      # Plain per-layout settings hashes for QA seeds.
      module Settings
        def settings_for(layout, component)
          method_name = "settings_for_#{layout}"
          raise ArgumentError, "Missing seed settings for #{layout}" unless respond_to?(method_name, true)

          send(method_name, component).merge("layout" => layout.to_s)
        end

        private

        def settings_for_verbose_cta(_component)
          cta_copy("Shape the city with us", "Join neighbours to co-create public space priorities.", "Start participating")
            .merge("button_url" => "/processes", "background_color" => "#020203", "text_color" => "white")
        end

        def settings_for_dual_path_cta(_component)
          dual_path_copy.merge(dual_path_colors).merge(
            "primary_button_url" => "/processes",
            "secondary_button_url" => "/processes",
            "alignment" => "left",
            "background_fit" => "cover"
          )
        end

        def settings_for_join_steps_cta(_component)
          step_fields(3).merge(localized("title", "How participation works"))
                        .merge(localized("button_label", "Begin"))
                        .merge("button_url" => "/processes", "background_color" => "#ffffff",
                               "text_color" => "black", "steps_json" => slots_json(3),
                               "background_fit" => "cover")
        end

        def settings_for_trust_quote_cta(_component)
          localized("quote", "This process helped us feel heard for the first time.")
            .merge(localized("attribution_name", "Alex Rivera"))
            .merge(localized("attribution_role", "Neighbourhood council"))
            .merge(localized("button_label", "Read stories"))
            .merge("button_url" => "/pages", "background_color" => "#020203", "text_color" => "white")
        end

        def settings_for_video_hero(_component)
          localized("eyebrow", "Watch the city move")
            .merge(localized("title", "Your city, your voice"))
            .merge(localized("button_label", "Take part"))
            .merge("button_url" => "/processes", "background_color" => "#020203", "text_color" => "white",
                   "title_position" => "middle_center")
        end

        def settings_for_photo_mission_hero(_component)
          photo_mission_copy.merge(
            "button_url" => "/processes",
            "background_color" => "#020203",
            "text_color" => "white",
            "overlay_strength" => "medium",
            "size" => "medium",
            "background_fit" => "contain"
          )
        end

        def settings_for_split_story_hero(_component)
          cta_copy("From empty lot to shared garden", "Residents transformed an unused plot into a meeting place.", "Discover more")
            .merge(localized("eyebrow", "Community story"))
            .merge("button_url" => "/processes", "background_color" => "#ffffff", "text_color" => "black", "image_side" => "right")
        end

        def settings_for_outcome_stats_hero(_component)
          stats_fields.merge(localized("title", "What we achieved"))
                      .merge(localized("intro", "Results from last year's participatory budget."))
                      .merge(localized("button_label", "See outcomes"))
                      .merge("button_url" => "/processes", "background_color" => "#020203",
                             "text_color" => "white", "stats_json" => slots_json(4))
        end

        def settings_for_focused_quick_proposal(component)
          fast_proposal_settings(component)
            .merge(localized("eyebrow", "One minute to share"))
            .merge("background_color" => "#020203", "text_color" => "white",
                   "background_fit" => "cover")
        end

        def settings_for_split_fast_proposal(component)
          fast_proposal_settings(component)
            .merge(localized("eyebrow", "Takes under two minutes"))
            .merge("form_side" => "left", "background_color" => "#020203", "text_color" => "white",
                   "background_fit" => "contain")
        end

        def settings_for_video_fast_proposal(component)
          fast_proposal_settings(component)
            .merge(localized("eyebrow", "Speak up from anywhere"))
            .merge("background_color" => "#020203", "text_color" => "white")
        end

        def settings_for_proposals_aside_fast_proposal(component)
          fast_proposal_settings(component)
            .merge(localized("eyebrow", "Ideas from your block"))
            .merge("background_color" => "#0b1d36", "text_color" => "white",
                   "background_fit" => "contain")
        end

        def settings_for_editorial_prose(_component)
          cta_copy("Why we open every decision", "Transparent agendas and public replies keep trust high.", "Our method")
            .merge(localized("eyebrow", "How we work"))
            .merge("button_url" => "/pages", "background_color" => "#ffffff", "text_color" => "black", "image_position" => "above")
        end

        def settings_for_media_aside(_component)
          cta_copy("Spaces that invite people in", "Photo essays from parks, markets, and libraries.", "Browse gallery")
            .merge("button_url" => "/pages", "background_color" => "#ffffff", "text_color" => "black",
                   "image_side" => "right", "asides_json" => slots_json(3))
        end

        def settings_for_topic_trio(_component)
          topic_fields.merge(localized("eyebrow", "This season"))
                      .merge(localized("title", "Priorities this year"))
                      .merge(localized("body", html("Three themes guide every assembly and workshop.")))
                      .merge(localized("button_label", "Explore themes"))
                      .merge("button_url" => "/processes", "background_color" => "#ffffff",
                             "text_color" => "black", "topics_json" => slots_json(3))
        end

        def settings_for_spacer(_component)
          { "background_color" => "#f7f7f7", "spacer_height" => "3rem" }
        end

        def settings_for_image(_component)
          { "background_color" => "#ffffff", "media_width" => "full" }
        end

        def settings_for_video(_component)
          { "background_color" => "#020203", "media_width" => "full" }
        end

        def settings_for_logo_showcase(_component)
          { "background_color" => "#ffffff", "logos_json" => logo_items.to_json }
        end

        def settings_for_brand_story(_component)
          timeline_settings("Our journey", brand_story_events)
        end

        def settings_for_roadmap(_component)
          roadmap_buttons(timeline_settings("Roadmap", roadmap_events))
        end

        def settings_for_impact_milestones(_component)
          timeline_settings("Impact milestones", impact_events)
        end

        def fast_proposal_settings(component)
          fast_proposal_copy.merge(
            "proposal_component_id" => component.id.to_s,
            "success_time" => "15",
            "default_title" => "Anonymous Proposal {{id}}",
            "default_title_connected" => "Proposal from {{id}}",
            "background_color" => "#ffffff",
            "text_color" => "black"
          )
        end

        def fast_proposal_copy
          localized("title", "Share your idea in under two minutes")
            .merge(localized("description", html("Describe the change you want. Guests verify with a phone number.")))
            .merge(localized("terms", html("By submitting you agree to the participation terms.")))
            .merge(localized("success_message", "Thanks! Your proposal is published."))
            .merge(localized("success_button_label", "View proposal"))
        end

        def cta_copy(title, body, button)
          localized("title", title)
            .merge(localized("body", html(body)))
            .merge(localized("button_label", button))
        end

        def dual_path_copy
          localized("title", "Two ways to get involved")
            .merge(localized("primary_title", "Share a proposal"))
            .merge(localized("primary_body", html("Suggest an idea for your street, park, or square.")))
            .merge(localized("primary_button_label", "Add a proposal"))
            .merge(localized("secondary_title", "Join a meeting"))
            .merge(localized("secondary_body", html("Meet facilitators and other residents face to face.")))
            .merge(localized("secondary_button_label", "See meetings"))
        end

        def dual_path_colors
          {
            "background_color" => "#020203",
            "text_color" => "white",
            "primary_background_color" => "#ffffff",
            "primary_text_color" => "black",
            "secondary_background_color" => "#155abf",
            "secondary_text_color" => "white"
          }
        end

        def photo_mission_copy
          localized("eyebrow", "Open until December")
            .merge(localized("title", "Mission: better streets"))
            .merge(localized("tagline", "Photograph issues, propose fixes, vote together."))
            .merge(localized("button_label", "Take part"))
        end

        def step_fields(count)
          (1..count).each_with_object({}) do |index, memo|
            memo.merge!(localized("step_#{index}_title", "Step #{index}"))
            memo.merge!(localized("step_#{index}_body", "Complete step #{index} with your neighbours."))
          end
        end

        def stats_fields
          [
            ["128", "Proposals"], ["42", "Projects funded"], ["3.2M", "Budget"], ["18k", "Voters"]
          ].each_with_index.with_object({}) do |((value, label), index), memo|
            slot = index + 1
            memo.merge!(localized("stat_#{slot}_value", value), localized("stat_#{slot}_label", label))
          end
        end

        def topic_fields
          [
            ["Mobility", "Safer streets and calmer neighbourhoods."],
            ["Climate", "Shade, water, and energy that lasts."],
            ["Care", "Services that reach every household."]
          ].each_with_index.with_object({}) do |((title, body), index), memo|
            slot = index + 1
            memo.merge!(localized("topic_#{slot}_title", title), localized("topic_#{slot}_body", body))
          end
        end

        def timeline_settings(title, events)
          fill_events(events).merge(localized("title", title)).merge(
            "background_color" => "#ffffff",
            "text_color" => "black",
            "events_json" => events.each_index.map { |i| { "slot" => i + 1, "highlighted" => i.zero? } }.to_json
          )
        end

        def fill_events(events)
          events.each_with_index.with_object({}) do |((date, event_title, body), index), memo|
            slot = index + 1
            memo.merge!(localized("event_#{slot}_date", date))
            memo.merge!(localized("event_#{slot}_title", event_title))
            memo.merge!(localized("event_#{slot}_body", body))
          end
        end

        def roadmap_buttons(base)
          (1..4).each_with_object(base) do |slot, memo|
            memo.merge!(localized("event_#{slot}_button_label", "Details"))
            memo["event_#{slot}_button_url"] = "/pages"
          end
        end

        def logo_items
          logo_media.keys.map { |name| name.to_s[/\d+\z/].to_i }.sort.map do |slot|
            { "slot" => slot, "alt" => localized_hash("Partner #{slot}") }
          end
        end

        def brand_story_events
          [
            ["2019", "First assembly", "Neighbours set shared rules for the district forum."],
            ["2021", "Digital rooms", "Hybrid meetings opened participation beyond the room."],
            ["2024", "City-wide scale", "Every district now runs Extra Blocks landing pages."]
          ]
        end

        def roadmap_events
          [
            ["Q1", "Gallery polish", "Faster admin previews for every layout."],
            ["Q2", "Fast Proposal", "Ephemeral guest create on the homepage."],
            ["Q3", "Analytics", "Lightweight impression counters for QA."],
            ["Q4", "Themes", "Tokenized color systems for host brands."]
          ]
        end

        def impact_events
          [
            ["Jan", "1k proposals", "Crossed one thousand published ideas."],
            ["Apr", "Budget vote", "Record turnout on neighbourhood projects."],
            ["Aug", "Open data", "Published anonymized participation metrics."],
            ["Nov", "Youth seat", "Youth council joined the steering group."]
          ]
        end

        def slots_json(count)
          (1..count).map { |slot| { "slot" => slot } }.to_json
        end
      end
    end
  end
end
