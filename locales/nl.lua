local Translations = {
    success = {
        you_have_been_clocked_in = "Je bent ingeklokt",
    },
    text = {
        point_exit_warehouse = "[E] Verlaat magazijn",
        point_enter_warehouse = "[E] Betreed magazijn",
        enter_warehouse= "Betreed magazijn",
        exit_warehouse= "Verlaat magazijn",
        clock_in = "[E] Klok in",
        clock_out = "[E] Klok uit",
        point_hand_in_package = "[E] Pakket inleveren",
        hand_in_package = "Pakket inleveren",
        point_get_package = "[E] Pak pakket",
        get_package = "Pak pakket",
        picking_up_the_package = "Pakket oppakken",
        unpacking_the_package = "Pakket uitpakken",
    },
    error = {
        you_have_clocked_out = "Je bent uitgeklokt"
    },
}


if GetConvar('qb_locale', 'en') == 'nl' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end