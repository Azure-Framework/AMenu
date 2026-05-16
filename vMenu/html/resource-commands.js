window.AZURE_RESOURCE_COMMANDS = {
  "citizen": {
    "title": "Citizen / Civilian Commands",
    "description": "Normal player commands found in the OCRP resource pack.",
    "items": [
      {
        "label": "Marketplace",
        "command": "market",
        "resource": "Az-Marketplace",
        "description": "Open the player marketplace listing/chat UI."
      },
      {
        "label": "Marketplace Inbox",
        "command": "marketinbox",
        "resource": "Az-Marketplace",
        "description": "Open marketplace messages/inbox and unread conversations."
      },
      {
        "label": "DS Marketplace",
        "command": "marketplace",
        "resource": "ds-marketplace",
        "description": "Open the alternate marketplace menu."
      },
      {
        "label": "PawnHub",
        "command": "pawnhub",
        "resource": "ORP-PawnHub",
        "description": "Open the PawnHub buying/selling page."
      },
      {
        "label": "Lottery",
        "command": "lottery",
        "resource": "az_lottery",
        "serverWrapper": "lotteryOpen",
        "description": "Open the Los Santos/San Andreas lottery ticket UI."
      },
      {
        "label": "Daily Check-In",
        "command": "daily",
        "resource": "azure_welcome_banner",
        "description": "Open the daily reward/check-in UI."
      },
      {
        "label": "Updates / Changelog",
        "command": "updates",
        "resource": "azure_welcome_banner",
        "description": "Open the server updates/changelog UI."
      },
      {
        "label": "Skills / Reputation",
        "command": "skills",
        "resource": "cw-rep",
        "description": "Open the skills and reputation menu."
      },
      {
        "label": "Emote Menu",
        "command": "emotemenu",
        "resource": "dpemotes",
        "description": "Open dpemotes menu."
      },
      {
        "label": "Play Emote",
        "command": "e",
        "resource": "dpemotes",
        "argsLabel": "Emote name",
        "defaultArgs": "wave",
        "description": "Run /e <emote>. Example: /e wave."
      },
      {
        "label": "Walking Styles",
        "command": "walks",
        "resource": "dpemotes",
        "description": "List/open walking style options."
      },
      {
        "label": "Set Walk Style",
        "command": "walk",
        "resource": "dpemotes",
        "argsLabel": "Walk style",
        "defaultArgs": "casual",
        "description": "Run /walk <style>. Example: /walk casual."
      },
      {
        "label": "Insurance",
        "command": "insurance",
        "resource": "qb-morsinsurance",
        "description": "Open the vehicle insurance UI."
      },
      {
        "label": "MORS Vehicle Services",
        "command": "mors",
        "resource": "qb-morsinsurance",
        "description": "Open MORS delivery/claim/insured vehicle services."
      },
      {
        "label": "Request Loading Song",
        "command": "requestsong",
        "resource": "OCRP-Loading",
        "argsLabel": "Song request text/link",
        "defaultArgs": "song name or link",
        "description": "Send a song request for the loading screen."
      },
      {
        "label": "Loading Shoutout",
        "command": "shoutout",
        "resource": "OCRP-Loading",
        "argsLabel": "Shoutout text",
        "defaultArgs": "Welcome to Azure Framework!",
        "description": "Send a shoutout for the loading screen system."
      },
      {
        "label": "Citizen Complaint / IAA",
        "command": "complaint",
        "resource": "ps-mdt",
        "description": "Open the officer complaint form."
      }
    ]
  },
  "housing": {
    "title": "Housing / Real Estate",
    "description": "Az-Housing QBCore portal, owner/seller helpers, admin placement, and quick how-to guidance.",
    "items": [
      {
        "label": "Open Housing Portal",
        "command": "housing",
        "resource": "Az-Housing / az-housing-qbcore",
        "description": "Open the public housing portal. Players can browse listings, inquire, buy/rent where allowed, view owned homes, and use keys, garages, upgrades, mailbox, stash, and wardrobe through the housing UI/target zones."
      },
      {
        "label": "Sell House to Player",
        "command": "house_sell",
        "resource": "Az-Housing / az-housing-qbcore",
        "argsLabel": "House ID, player ID, price",
        "defaultArgs": "1 1 75000",
        "description": "Owner/agent sell helper. Newer builds use /house_sell <houseId> <playerId> <price>; some builds accept /house_sell <playerId> <price> when standing at the property."
      },
      {
        "label": "Az Housing Sell Helper",
        "command": "azhousing_sell",
        "resource": "Az-Housing / az-housing-qbcore",
        "argsLabel": "House ID, player ID, price",
        "defaultArgs": "1 1 75000",
        "description": "Alternate sell command for the same owner/agent sale flow."
      },
      {
        "label": "Admin Placement / Edit Mode",
        "command": "housingedit",
        "resource": "Az-Housing / az-housing-qbcore",
        "description": "Admin tool for creating/editing houses, doors, garages, interior placement, furniture points, stash, wardrobe, mailbox, and listing setup."
      },
      {
        "label": "Reload Housing Data",
        "command": "azhousing_reload",
        "resource": "Az-Housing / az-housing-qbcore",
        "description": "Admin reload for housing data after setup changes."
      },
      {
        "label": "Housing Weather / Admin UI",
        "command": "weather",
        "resource": "Az-Housing",
        "description": "Admin weather UI retained in some Az-Housing builds. Housing still checks QBCore/ACE/role permissions."
      },
      {
        "label": "Home Owner Guide",
        "type": "info",
        "resource": "Az-Housing / az-housing-qbcore",
        "description": "Owners use /housing or property target zones to enter, lock/unlock, manage keys, use stash/wardrobe, use mailbox, access garage storage, and buy upgrades. Ownership/keys are tied to QBCore citizenid so houses stay with the character."
      },
      {
        "label": "Seller / Agent Guide",
        "type": "info",
        "resource": "Az-Housing / az-housing-qbcore",
        "description": "Real estate agents create/edit listings, add images/details/prices, answer inquiries, and use /house_sell or /azhousing_sell to transfer property to a buyer when payment and RP are complete."
      },
      {
        "label": "Admin Housing Guide",
        "type": "info",
        "resource": "Az-Housing / az-housing-qbcore",
        "description": "Admins go to the property, use /housingedit, create the house, place the front door, add garage spawn/storage if needed, set interior/stash/wardrobe/mailbox/upgrades/listing data, then reload with /azhousing_reload or restart if needed."
      },
      {
        "label": "Police Breach Guide",
        "type": "info",
        "resource": "Az-Housing / az-housing-qbcore",
        "description": "Police jobs configured in housing config can breach/force access through the housing target/menu flow. This is job/permission checked by the housing resource, not bypassed by vMenu."
      }
    ]
  },
  "outdoors": {
    "title": "Hunting / Fishing / Outdoors",
    "description": "Stoic-Hunting QBCore, Az-Fishing KVP, and Az-FishFinder sonar commands.",
    "items": [
      {
        "label": "Open MyODFW / Outdoors App",
        "command": "myodfw",
        "resource": "Stoic-Hunting-QBCore / Stoic-Hunting",
        "description": "Civilian license, tags, account, and harvest portfolio UI. Hunting uses qb-inventory for harvested items and QBCore metadata for licenses/tags."
      },
      {
        "label": "Open Outdoors App Alias",
        "command": "outdoors",
        "resource": "Stoic-Hunting-QBCore / Stoic-Hunting",
        "description": "Alias for /myodfw."
      },
      {
        "label": "LEO / Warden Lookup",
        "command": "odfwleo",
        "resource": "Stoic-Hunting-QBCore / Stoic-Hunting",
        "description": "Police/game warden lookup dashboard for licenses, tags, harvest history, and citizen hunting/fishing compliance."
      },
      {
        "label": "Skin / Harvest Animal",
        "command": "skinanimal",
        "resource": "Stoic-Hunting-QBCore / Stoic-Hunting",
        "description": "Fallback command to field dress the closest dead animal if target interaction is disabled or unavailable."
      },
      {
        "label": "Start Fishing",
        "command": "fish",
        "resource": "Az-Fishing",
        "description": "Start the KVP fishing minigame. Fishing does not use qb-inventory; catches are stored in the fishing KVP portfolio."
      },
      {
        "label": "Fish Portfolio",
        "command": "fishmenu",
        "resource": "Az-Fishing",
        "description": "Open the KVP fish portfolio/inventory and sell/view saved catches."
      },
      {
        "label": "Fish Finder / Boat Sonar",
        "command": "fishfinder",
        "resource": "Az-FishFinder",
        "description": "Open the boat fish finder. Big fish, school, and trophy sonar marks affect Az-Fishing catch odds when fishing from a boat."
      },
      {
        "label": "Boat Anchor",
        "command": "anchor",
        "resource": "Az-Fishing",
        "description": "Anchor or raise the nearest/current boat from the Az-Fishing anchor module."
      },
      {
        "label": "How Hunting Works",
        "type": "info",
        "resource": "Stoic-Hunting-QBCore / Stoic-Hunting",
        "description": "Players buy licenses/tags in MyODFW, hunt legal animals, harvest with target or /skinanimal, receive unique qb-inventory harvest items with species/quality/kill metadata, then sell through configured buyer/market flow. Payout depends on animal species, meat/hide value, kill method, and quality."
      },
      {
        "label": "How Fishing Works",
        "type": "info",
        "resource": "Az-Fishing + Az-FishFinder",
        "description": "Players fish near valid water or from a boat. Fish stay in KVP storage. If a boat has sonar open, Az-FishFinder exports recent sonar signals to Az-Fishing so big/school/trophy signals influence catch chances."
      }
    ]
  },
  "publicworks": {
    "title": "Public Works / SADOT / SAG&E",
    "description": "Unified public works callouts plus legacy SADOT roadworks commands.",
    "items": [
      {
        "label": "Open Public Works Dispatch",
        "command": "publicworks",
        "resource": "az_publicworks_utilities",
        "description": "Open the unified SADOT + SAG&E dispatch UI with active callouts, assigned calls, urgent markers, part markers, and live GTA map."
      },
      {
        "label": "Public Works Dispatch Alias",
        "command": "pw",
        "resource": "az_publicworks_utilities",
        "description": "Alias for /publicworks."
      },
      {
        "label": "SADOT Dispatch Alias",
        "command": "sadot",
        "resource": "az_publicworks_utilities / az_construction_roadworks",
        "description": "Open SADOT/public works dispatch. Also works with the older roadworks resource."
      },
      {
        "label": "SAG&E Dispatch Alias",
        "command": "sage",
        "resource": "az_publicworks_utilities",
        "description": "Open the utility-side dispatch UI for electric/gas/water calls."
      },
      {
        "label": "Utilities Dispatch Alias",
        "command": "utilities",
        "resource": "az_publicworks_utilities",
        "description": "Open the utility/public works dispatch UI."
      },
      {
        "label": "RoadWorks Dispatch Alias",
        "command": "roadworks",
        "resource": "az_publicworks_utilities",
        "description": "Open the roadworks/public works dispatch UI."
      },
      {
        "label": "Accept Public Works Call",
        "command": "pwaccept",
        "resource": "az_publicworks_utilities",
        "description": "Accept the nearest/current public works callout if config allows accept commands and your job can work that department."
      },
      {
        "label": "Accept SADOT Call Alias",
        "command": "sadotaccept",
        "resource": "az_publicworks_utilities / az_construction_roadworks",
        "description": "Legacy SADOT accept alias for nearby/current callouts."
      },
      {
        "label": "Accept SAG&E Call Alias",
        "command": "sageaccept",
        "resource": "az_publicworks_utilities",
        "description": "Utility accept alias for nearby/current SAG&E calls."
      },
      {
        "label": "Repair / Complete Callout",
        "command": "roadfix",
        "resource": "az_publicworks_utilities / az_construction_roadworks",
        "description": "Start/complete the nearest accepted repair when you are at the install/service point."
      },
      {
        "label": "Public Works Fix Alias",
        "command": "pwfix",
        "resource": "az_publicworks_utilities",
        "description": "Alias for completing the nearest accepted public works callout."
      },
      {
        "label": "Utility Fix Alias",
        "command": "utilityfix",
        "resource": "az_publicworks_utilities",
        "description": "Alias for completing utility-side work."
      },
      {
        "label": "SAG&E Fix Alias",
        "command": "sagefix",
        "resource": "az_publicworks_utilities",
        "description": "Alias for completing SAG&E work."
      },
      {
        "label": "Cancel Stuck Repair",
        "command": "roadfixcancel",
        "resource": "az_publicworks_utilities / az_construction_roadworks",
        "description": "Cancel a stuck repair animation/state."
      },
      {
        "label": "Citizen Report: Road",
        "command": "pwcall",
        "resource": "az_publicworks_utilities",
        "argsLabel": "Call type",
        "defaultArgs": "road",
        "description": "Citizen report to public works. Example: /pwcall road."
      },
      {
        "label": "Citizen Report: Signal",
        "command": "pwcall",
        "resource": "az_publicworks_utilities",
        "argsLabel": "Call type",
        "defaultArgs": "signal",
        "description": "Citizen report for a traffic signal issue."
      },
      {
        "label": "Citizen Report: Light",
        "command": "pwcall",
        "resource": "az_publicworks_utilities",
        "argsLabel": "Call type",
        "defaultArgs": "light",
        "description": "Citizen report for street light or pole issues."
      },
      {
        "label": "Citizen Report: Electric",
        "command": "pwcall",
        "resource": "az_publicworks_utilities",
        "argsLabel": "Call type",
        "defaultArgs": "electric",
        "description": "Citizen report for an electric outage/service issue."
      },
      {
        "label": "Citizen Report: Transformer",
        "command": "pwcall",
        "resource": "az_publicworks_utilities",
        "argsLabel": "Call type",
        "defaultArgs": "transformer",
        "description": "Citizen report for a transformer/utility box issue."
      },
      {
        "label": "Citizen Report: Gas",
        "command": "pwcall",
        "resource": "az_publicworks_utilities",
        "argsLabel": "Call type",
        "defaultArgs": "gas",
        "description": "Citizen report for a gas leak investigation."
      },
      {
        "label": "Citizen Report: Water",
        "command": "pwcall",
        "resource": "az_publicworks_utilities",
        "argsLabel": "Call type",
        "defaultArgs": "water",
        "description": "Citizen report for a water leak/main issue."
      },
      {
        "label": "Citizen Report: Hydrant",
        "command": "pwcall",
        "resource": "az_publicworks_utilities",
        "argsLabel": "Call type",
        "defaultArgs": "hydrant",
        "description": "Citizen report for damaged hydrant/service issue."
      },
      {
        "label": "Quick Road Call",
        "command": "roadcall",
        "resource": "az_publicworks_utilities",
        "description": "Quick citizen road hazard/report alias."
      },
      {
        "label": "Quick Utility Call",
        "command": "utilitycall",
        "resource": "az_publicworks_utilities",
        "argsLabel": "Utility type",
        "defaultArgs": "electric",
        "description": "Quick utility call alias. Example: /utilitycall electric."
      },
      {
        "label": "Quick Gas Call",
        "command": "gascall",
        "resource": "az_publicworks_utilities",
        "description": "Quick gas leak call alias."
      },
      {
        "label": "Quick Water Call",
        "command": "watercall",
        "resource": "az_publicworks_utilities",
        "description": "Quick water leak call alias."
      },
      {
        "label": "Quick Power Call",
        "command": "powercall",
        "resource": "az_publicworks_utilities",
        "description": "Quick power outage call alias."
      },
      {
        "label": "How Public Works Works",
        "type": "info",
        "resource": "az_publicworks_utilities",
        "description": "SADOT handles roads/signs/cones/barriers/signals/crash hardware. SAG&E handles electric, gas, water, hydrants, transformers and outages. Random/citizen/crash callouts appear in dispatch, crews accept, pick up fallen parts where required, return to the service point, complete the minigame, and get paid based on call type, travel, response time, and quality."
      }
    ]
  },
  "drugs": {
    "title": "Drugs / Illegal RP Systems",
    "description": "Drug system help and safe utility commands. Direct harvest/process actions stay inside target zones/items for serious RP.",
    "items": [
      {
        "label": "Drug Prop Fix",
        "command": "propfix",
        "resource": "ps-drugprocessing",
        "description": "Clean up/reset stuck drug-processing props near the player. This is the only direct ps-drugprocessing slash command found in the resource."
      },
      {
        "label": "How ps-drugprocessing Works",
        "type": "info",
        "resource": "ps-drugprocessing",
        "description": "Cocaine, meth, heroin, LSD/chemicals, acid/sodium/sulfuric, and weed flows are mostly target/item/location driven. Players should use configured locations, items, and qb-target interactions rather than a vMenu button that teleports or grants drugs."
      },
      {
        "label": "Cocaine Flow",
        "type": "info",
        "resource": "ps-drugprocessing",
        "description": "Typical flow: pick coca leaves at configured farm/target, process to cocaine powder, package into baggies/bricks at configured processing points, then sell through the server drug-sale flow."
      },
      {
        "label": "Meth Flow",
        "type": "info",
        "resource": "ps-drugprocessing",
        "description": "Typical flow: collect/buy chemicals, enter/use the lab if configured, control processing steps/minigames, and package product. The resource handles item checks and police/server risk rules."
      },
      {
        "label": "Heroin / Poppy Flow",
        "type": "info",
        "resource": "ps-drugprocessing",
        "description": "Typical flow: gather poppy materials, process at configured station, and package/sell through your economy setup."
      },
      {
        "label": "LSD / Chemical Flow",
        "type": "info",
        "resource": "ps-drugprocessing",
        "description": "Chemical collection and LSD processing are handled by configured zones, target options, and item requirements. Use the in-world process rather than admin-style command shortcuts."
      },
      {
        "label": "Weed Planting Flow",
        "type": "info",
        "resource": "ps-weedplanting / qb-weed / uniq-weedsystem",
        "description": "Planting systems use seeds/items, growth timers, water/fertilizer/quality data, and harvest interactions. No normal player command is needed unless the resource config adds one."
      },
      {
        "label": "Serious RP Note",
        "type": "info",
        "resource": "Drug resources",
        "description": "This vMenu only exposes safe help/cleanup. It does not add buttons that grant product, skip processing, bypass item checks, or reveal hidden locations."
      }
    ]
  },
  "camping": {
    "title": "Camping / RP Props",
    "description": "Camping commands from az-camping.",
    "items": [
      {
        "label": "Place Tent",
        "command": "tent",
        "resource": "az-camping",
        "description": "Place/use a tent RP prop."
      },
      {
        "label": "Place Campfire",
        "command": "campfire",
        "resource": "az-camping",
        "description": "Place/use a campfire RP prop."
      },
      {
        "label": "Place Chair",
        "command": "chair",
        "resource": "az-camping",
        "description": "Place/use a camping chair RP prop."
      },
      {
        "label": "Remove Camping Props",
        "command": "campremove",
        "resource": "az-camping",
        "description": "Remove your camping props."
      }
    ]
  },
  "jobs": {
    "title": "Jobs / Work Commands",
    "description": "General job-facing commands for trucking, food jobs, VU, weapon shops, and job apps. Public Works has its own full category now.",
    "items": [
      {
        "label": "Trucking Dispatch Board",
        "command": "trucking",
        "resource": "qb_truckin / randol_trucking",
        "serverWrapper": "truckingOpen",
        "description": "Open the ATS/QB trucking dispatch board."
      },
      {
        "label": "Abort Active Haul",
        "command": "aborthaul",
        "resource": "qb_truckin",
        "description": "Abort your current trucking haul."
      },
      {
        "label": "Open Public Works Dispatch",
        "command": "publicworks",
        "resource": "az_publicworks_utilities",
        "description": "Open SADOT + SAG&E dispatch from the jobs menu too."
      },
      {
        "label": "VU Invoice Player",
        "command": "invoice",
        "resource": "qb-vanillaunicorn",
        "serverWrapper": "vuInvoice",
        "argsLabel": "Player ID and amount",
        "defaultArgs": "1 500",
        "description": "VU job invoice. Usage: /invoice <player id> <amount>."
      },
      {
        "label": "Armory",
        "command": "armory",
        "resource": "Az-WeaponShop",
        "description": "Open job/shop armory where allowed."
      },
      {
        "label": "Emergency Vehicle Spawner",
        "command": "evspawn",
        "resource": "QBcore_Emergency_Vehicle_Spawner",
        "description": "Open emergency vehicle spawner fallback command."
      },
      {
        "label": "Air Radar",
        "command": "airradar",
        "resource": "az_airradar",
        "description": "Open/toggle aircraft radar tool."
      },
      {
        "label": "Weapon Sling",
        "command": "sling",
        "resource": "fjh-sling",
        "serverWrapper": "weaponSling",
        "description": "Change weapon sling position."
      },
      {
        "label": "Taco Job Guide",
        "type": "info",
        "resource": "bd-tacojob",
        "description": "Taco job food/drink/counter/garage actions are target-zone based. Use the workplace stations instead of a slash command where possible."
      },
      {
        "label": "Gardening Guide",
        "type": "info",
        "resource": "HPNGD-Gardening",
        "description": "Gardening jobs are generally configured through in-world zones/items. Use the resource interaction points; vMenu does not grant items or skip the job flow."
      },
      {
        "label": "Chicken Job Guide",
        "type": "info",
        "resource": "mb-chicken",
        "description": "Chicken job actions are normally in-world interaction/target based. Use the job stations from the resource."
      }
    ]
  },
  "law": {
    "title": "Police / EMS / Government",
    "description": "Law enforcement, MDT, lockdown, radar, emergency utility commands, and outdoor enforcement.",
    "items": [
      {
        "label": "Open MDT",
        "command": "mdt",
        "resource": "ps-mdt",
        "description": "Open the MDT. Civilians get civilian access if enabled; LEO gets duty tools."
      },
      {
        "label": "Set MDT Message of the Day",
        "command": "motd",
        "resource": "ps-mdt",
        "argsLabel": "Message text",
        "defaultArgs": "Patrol briefing in effect.",
        "description": "Boss police command. Usage: /motd <message>."
      },
      {
        "label": "Citizen Complaint / IAA",
        "command": "complaint",
        "resource": "ps-mdt",
        "description": "Open the officer complaint form."
      },
      {
        "label": "LEO / Warden Outdoors Lookup",
        "command": "odfwleo",
        "resource": "Stoic-Hunting-QBCore / Stoic-Hunting",
        "description": "Game warden/police lookup for hunting and fishing licenses/tags/harvests."
      },
      {
        "label": "Create Government Lockdown",
        "command": "lock",
        "resource": "goverment-lockdown",
        "serverWrapper": "lockdownCreate",
        "description": "Create a lockdown blip/zone if your job is allowed."
      },
      {
        "label": "End Government Lockdown",
        "command": "unlock",
        "resource": "goverment-lockdown",
        "serverWrapper": "lockdownRemove",
        "description": "Remove the lockdown blip/zone if your job is allowed."
      },
      {
        "label": "Radar Remote",
        "command": "radar_remote",
        "resource": "wk_wars2x",
        "description": "Open/toggle radar remote."
      },
      {
        "label": "Front Radar Antenna",
        "command": "radar_fr_ant",
        "resource": "wk_wars2x",
        "description": "Toggle front radar antenna."
      },
      {
        "label": "Rear Radar Antenna",
        "command": "radar_bk_ant",
        "resource": "wk_wars2x",
        "description": "Toggle rear radar antenna."
      },
      {
        "label": "Front Radar Camera",
        "command": "radar_fr_cam",
        "resource": "wk_wars2x",
        "description": "Toggle front radar camera."
      },
      {
        "label": "Rear Radar Camera",
        "command": "radar_bk_cam",
        "resource": "wk_wars2x",
        "description": "Toggle rear radar camera."
      },
      {
        "label": "Radar Key Lock",
        "command": "radar_key_lock",
        "resource": "wk_wars2x",
        "description": "Lock/unlock radar key control."
      },
      {
        "label": "Reset Radar Data",
        "command": "reset_radar_data",
        "resource": "wk_wars2x",
        "description": "Clear radar plate/speed data."
      },
      {
        "label": "ULC Light Controller",
        "command": "ulc",
        "resource": "ulc",
        "description": "Open the ULC emergency light controller."
      },
      {
        "label": "ULC Stage Up",
        "command": "ulc:stage_up",
        "resource": "ulc",
        "description": "Move emergency light stage up."
      },
      {
        "label": "ULC Stage Down",
        "command": "ulc:stage_down",
        "resource": "ulc",
        "description": "Move emergency light stage down."
      },
      {
        "label": "ULC Cycle Stage",
        "command": "ulc:stage_cycle",
        "resource": "ulc",
        "description": "Cycle emergency light stage."
      },
      {
        "label": "Mute Lights",
        "command": "mutelights",
        "resource": "ulc",
        "description": "Mute light controller sounds."
      },
      {
        "label": "Blackout",
        "command": "blackout",
        "resource": "ulc",
        "description": "Toggle blackout lighting mode."
      }
    ]
  },
  "vehicles": {
    "title": "Vehicle / Offroad / Mechanic Commands",
    "description": "Vehicle systems, offroad, winch, suspension, plates, indicators, and traffic tools.",
    "items": [
      {
        "label": "Vanity Plate Shop",
        "command": "vanityplate",
        "resource": "Az-VehicleSystems/Az-Plates",
        "description": "Open/buy a vanity plate item."
      },
      {
        "label": "Suspension UI",
        "command": "susui",
        "resource": "Az-VehicleSystems/Az-Suspension",
        "description": "Open suspension tuning UI."
      },
      {
        "label": "Suspension View",
        "command": "susview",
        "resource": "Az-VehicleSystems/Az-Suspension",
        "description": "View current suspension values."
      },
      {
        "label": "Suspension Copy",
        "command": "suscopy",
        "resource": "Az-VehicleSystems/Az-Suspension",
        "description": "Copy current suspension data."
      },
      {
        "label": "Suspension Refresh",
        "command": "susrefresh",
        "resource": "Az-VehicleSystems/Az-Suspension",
        "description": "Refresh/apply stored suspension settings."
      },
      {
        "label": "Suspension Set",
        "command": "susset",
        "resource": "Az-VehicleSystems/Az-Suspension",
        "argsLabel": "Suspension args",
        "defaultArgs": "height 0.0",
        "description": "Advanced suspension set command. Usage depends on Az-Suspension."
      },
      {
        "label": "Suspension Add",
        "command": "susadd",
        "resource": "Az-VehicleSystems/Az-Suspension",
        "argsLabel": "Suspension add args",
        "defaultArgs": "height 0.01",
        "description": "Advanced suspension add command."
      },
      {
        "label": "Suspension Reset",
        "command": "susreset",
        "resource": "Az-VehicleSystems/Az-Suspension",
        "description": "Reset suspension values."
      },
      {
        "label": "Suspension Preset",
        "command": "suspreset",
        "resource": "Az-VehicleSystems/Az-Suspension",
        "argsLabel": "Preset name/id",
        "defaultArgs": "default",
        "description": "Apply a suspension preset."
      },
      {
        "label": "Suspension Help",
        "command": "sushelp",
        "resource": "Az-VehicleSystems/Az-Suspension",
        "description": "Show suspension command help."
      },
      {
        "label": "Lock Front Differential",
        "command": "lockfront",
        "resource": "Az-VehicleSystems/Az-Offroad",
        "description": "Toggle front differential lock."
      },
      {
        "label": "Lock Rear Differential",
        "command": "lockrear",
        "resource": "Az-VehicleSystems/Az-Offroad",
        "description": "Toggle rear differential lock."
      },
      {
        "label": "Lock Real/AWD Mode",
        "command": "lockreal",
        "resource": "Az-VehicleSystems/Az-Offroad",
        "description": "Toggle real lock/AWD helper from offroad system."
      },
      {
        "label": "Traction Boards",
        "command": "boards",
        "resource": "Az-VehicleSystems/Az-Offroad",
        "description": "Use/toggle traction boards."
      },
      {
        "label": "Air Down Tires",
        "command": "airdown",
        "resource": "Az-VehicleSystems/Az-Offroad",
        "argsLabel": "Optional wheel/all",
        "defaultArgs": "all",
        "description": "Air down tires. Example: /airdown all."
      },
      {
        "label": "Air Up Tires",
        "command": "airup",
        "resource": "Az-VehicleSystems/Az-Offroad",
        "argsLabel": "Optional wheel/all",
        "defaultArgs": "all",
        "description": "Air tires back up. Example: /airup all."
      },
      {
        "label": "Winch Menu",
        "command": "winch",
        "resource": "Az-VehicleSystems/Az-Offroad",
        "description": "Open/toggle winch control."
      },
      {
        "label": "Winch Remote",
        "command": "winchremote",
        "resource": "Az-VehicleSystems/Az-Offroad",
        "description": "Open/toggle remote winch UI."
      },
      {
        "label": "Detach Winch",
        "command": "winchdetach",
        "resource": "Az-VehicleSystems/Az-Offroad",
        "description": "Detach the active winch rope."
      },
      {
        "label": "Tire FX Debug",
        "command": "tirefx",
        "resource": "Az-VehicleSystems/Az-Offroad",
        "argsLabel": "on/off",
        "defaultArgs": "on",
        "description": "Toggle tire particle/debug effects."
      },
      {
        "label": "Wheel Debug",
        "command": "wheeldebug",
        "resource": "Az-VehicleSystems/Az-Offroad",
        "argsLabel": "on/off",
        "defaultArgs": "on",
        "description": "Toggle wheel debug overlay."
      },
      {
        "label": "Wheel Speed Debug",
        "command": "wheelspeeddebug",
        "resource": "Az-VehicleSystems/Az-Offroad",
        "argsLabel": "on/off",
        "defaultArgs": "on",
        "description": "Toggle wheel speed debug overlay."
      },
      {
        "label": "Surface Debug",
        "command": "surfaceDebug",
        "resource": "Az-VehicleSystems/Az-Offroad",
        "argsLabel": "on/off",
        "defaultArgs": "on",
        "description": "Toggle surface material debug."
      },
      {
        "label": "Custom Traffic Menu",
        "command": "ctraffic",
        "resource": "az_customtraffic",
        "description": "Open custom traffic route/zone editor menu."
      },
      {
        "label": "Left Indicator",
        "command": "indicate_left",
        "resource": "jg-vehicleindicators-main",
        "description": "Toggle left vehicle indicator."
      },
      {
        "label": "Right Indicator",
        "command": "indicate_right",
        "resource": "jg-vehicleindicators-main",
        "description": "Toggle right vehicle indicator."
      },
      {
        "label": "Hazards",
        "command": "hazards",
        "resource": "jg-vehicleindicators-main",
        "description": "Toggle vehicle hazard lights."
      }
    ]
  },
  "admin": {
    "title": "Admin / Staff Commands",
    "description": "Admin commands found in the resource pack. The source resources still enforce permissions.",
    "staffOnly": true,
    "items": [
      {
        "label": "Admin Panel",
        "command": "adminpanel",
        "resource": "ORP-AdminPanel",
        "description": "Open the ORP admin panel."
      },
      {
        "label": "Housing Edit Mode",
        "command": "housingedit",
        "resource": "Az-Housing / az-housing-qbcore",
        "description": "Open housing admin placement/edit mode."
      },
      {
        "label": "Reload Housing Data",
        "command": "azhousing_reload",
        "resource": "Az-Housing / az-housing-qbcore",
        "description": "Reload housing data from storage."
      },
      {
        "label": "Force Public Works Random Call",
        "command": "pwrandom",
        "resource": "az_publicworks_utilities",
        "argsLabel": "Optional call type",
        "defaultArgs": "gas",
        "description": "Admin testing: force a public works random callout. Examples: /pwrandom gas, /pwrandom water, /pwrandom signal, /pwrandom transformer."
      },
      {
        "label": "Force Lottery Draw",
        "command": "lotterydraw",
        "resource": "az_lottery",
        "description": "Force the current lottery draw. Admin only."
      },
      {
        "label": "Lottery Fund Status",
        "command": "lotteryfund",
        "resource": "az_lottery",
        "description": "Check state lottery fund/reserve/jackpot. Admin only."
      },
      {
        "label": "Force Treasure Crate",
        "command": "forcetreasure",
        "resource": "CrateSystem",
        "description": "Force a global treasure crate spawn. Admin only."
      },
      {
        "label": "Reload Custom Traffic Server",
        "command": "ctraffic_reload_server",
        "resource": "az_customtraffic",
        "description": "Reload custom traffic routes/zones on the server."
      },
      {
        "label": "Add Custom Traffic Node",
        "command": "ctraffic_addnode",
        "resource": "az_customtraffic",
        "description": "Add a traffic route node at your current position."
      },
      {
        "label": "Remove Owned Vehicle By Plate",
        "command": "morsremove",
        "resource": "qb-morsinsurance",
        "argsLabel": "Plate",
        "defaultArgs": "PLATE123",
        "description": "Admin remove broken owned vehicle by plate. Usage: /morsremove PLATE."
      },
      {
        "label": "Clear Vehicle Fingerprints",
        "command": "clearvehicleprint",
        "resource": "Az-FingerPrints",
        "argsLabel": "Plate",
        "defaultArgs": "PLATE123",
        "description": "Clear fingerprint evidence for a vehicle plate."
      },
      {
        "label": "Give Skill",
        "command": "giveskill",
        "resource": "cw-rep",
        "argsLabel": "Player ID, skill name, amount",
        "defaultArgs": "1 lockpicking 100",
        "description": "Admin skill adjustment. Usage: /giveskill <id> <skill> <amount>."
      },
      {
        "label": "Fetch Skills",
        "command": "fetchSkills",
        "resource": "cw-rep",
        "argsLabel": "Player ID",
        "defaultArgs": "1",
        "description": "Print/fetch player skill data."
      },
      {
        "label": "JD Logs",
        "command": "jdlogs",
        "resource": "ORP-Logs",
        "description": "Open/view JD logs command."
      },
      {
        "label": "Screenshot Player",
        "command": "screenshot",
        "resource": "ORP-Logs",
        "argsLabel": "Player ID",
        "defaultArgs": "1",
        "description": "Take/request a player screenshot through ORP-Logs."
      },
      {
        "label": "Fingerprints Debug",
        "command": "fingerdebug",
        "resource": "Az-FingerPrints",
        "description": "Toggle fingerprint debug."
      },
      {
        "label": "Emergency Spawner Debug",
        "command": "evsdebug",
        "resource": "QBcore_Emergency_Vehicle_Spawner",
        "description": "Show emergency vehicle spawner diagnostics."
      },
      {
        "label": "Welcome Banner Test",
        "command": "welcometest",
        "resource": "azure_welcome_banner",
        "description": "Test the welcome banner UI."
      },
      {
        "label": "NPC 911 Test",
        "command": "npc911test",
        "resource": "az-npcreport/az-npc-imperialcad",
        "description": "Trigger a test NPC 911 report."
      },
      {
        "label": "NPC 911 CAD Test",
        "command": "npc911cadtest",
        "resource": "az-npc-imperialcad",
        "description": "Trigger a test ImperialCAD NPC 911 call."
      },
      {
        "label": "LVC Factory Reset",
        "command": "lvcfactoryreset",
        "resource": "lvc",
        "description": "Factory reset LVC local storage/settings."
      },
      {
        "label": "LVC Dump KVP",
        "command": "lvcdumpkvp",
        "resource": "lvc",
        "description": "Dump LVC KVP data for diagnostics."
      },
      {
        "label": "ULC Reset",
        "command": "ulcReset",
        "resource": "ulc",
        "description": "Reset ULC local state."
      },
      {
        "label": "Hayden VU Test",
        "command": "hayden:test",
        "resource": "qb-vanillaunicorn",
        "description": "Debug/test command found in VU client."
      }
    ]
  }
};
