mkdir -p PDFs

#echo "[Deploy PDFs] Removing previous PDFs"
rm -rf ./PDFs

songs=(42_bailando_bachata 41_caramelo_con_picante 40_familia_intro 39_carnaval 38_fragilidad 37_stand_by_me 36_nossa 35_lambada 34_chan_chan 33_bachata 32_me_quedo_contigo 31_palla_voy 30_el_cantante 29_bailando 28_vivir_mi_vida 27_conga 26_senorita 25_lamento_boliviano 24_via 23_aint_nobody 22_perfect 21_la_sabrosa 20_hello 19_ran_kan_kan 18_i_want_you_back 17_sera_que_no_me_amas 16_yo_no_tengo_soledad 15_star_gees 14_canalla 13_would_i_lie 12_incondicional 11_sunshine 10_brocoli 9_baila_conmigo 8_oye_como_va 7_lonely_boy 6_wake_up_song 5_micaela 4_all_of_me 3_los_campeones_de_la_salsa 2_yo_no_se_manana 1_letam)
#for d in `find . -maxdepth 1 -type d \( ! -name . ! -name PDFs ! -name templates ! -name inactive \) | sort -Vr`
for d in ${songs[@]}
do
	d=${d#"./"}
	#echo "[Deploy PDFs] Entering: $d"
	cd $d
	if compgen -G "*.pdf" > /dev/null; then
		#echo "[Deploy PDFs] Removing Lilypond temp files"
		#rm lilypond-tmp*
		#echo "[Deploy PDFs] Copying: $num PDF files to PDFs/$d"
		mkdir -p ../PDFs/$d
		cp *.pdf ../PDFs/$d

		#echo "[Deploy PDFs] Loading song data"
		id_from_dir=`echo "$d" | cut -d'_' -f1`
		songname=`echo "$d" | cut -d'_' -f2-`
		instruments=(ireal trombone alto_sax tenor_sax trumpet bass piano conga timbales)
		#echo "[Deploy PDFs] Found id: $id_from_dir"
		#echo "[Deploy PDFs] Found songname: $songname"
		#echo "[Deploy PDFs] Loaded instruments:"
		#for instrument in ${instruments[@]}; do echo $instrument; done
		source ${songname}.bashconfig
		#echo "[Deploy PDFs] Loaded bashconfig file with id: $ID and title: $TITLE"
		statusinfo=""
		statusclass="has-vivid-green-cyan-color"
		if [ "$STATUS" = "inactive" ]; then
            statusinfo=" (inactive)"
            statusclass="has-cyan-bluish-gray-color"
		fi
		if [ "$STATUS" = "?" ]; then
            statusinfo=" (?)"
            statusclass="has-vivid-cyan-blue-color"
		fi
		if [ "$STATUS" = "miniband" ]; then
            statusinfo=" (miniband)"
            statusclass="has-vivid-purple-color"
		fi
		if [ "$STATUS" = "considering" ]; then
            statusinfo=" (considering)"
            statusclass="has-luminous-vivid-amber-color"
		fi
		sheets_dir="https://github.com/lacimarsik/lafamiliasalsaband.com/blob/main/sheets"
		sheet_links=""
		for instrument in ${instruments[@]}; do sheet_links+="<a rel=\"noreferrer noopener\" href=\"${sheets_dir}/${d}/${songname}_${instrument}.pdf\" target=\"_blank\">${instrument}</a> "; done
		
		#echo "[Deploy PDFs] Creating HTML for web"
		echo ""
		echo "<p class=\"${statusclass} has-text-color\"><strong>#${ID}${statusinfo} ${TITLE} (${INTERPRET})</strong></p>"
	    echo ""
	    echo "<details class=\"wp-block-details ${TEMPOCLASS} has-text-color\"><summary>Instructions: ${TEMPO} (click to expand)</summary>"
		echo "<p class=\"has-cyan-bluish-gray-color has-text-color\">${INSTRUCTIONS}</p>"
		echo "</details>"
		echo ""
		echo "<details class=\"wp-block-details\"><summary>Resources</summary>"
		echo "<p><a rel=\"noreferrer noopener\" href=\"${MP3}\" target=\"_blank\">mp3</a> <a rel=\"noreferrer noopener\" href=\"${TEXT}\" target=\"_blank\">text</a> <a rel=\"noreferrer noopener\" href=\"${CHORD}\" target=\"_blank\">chord</a> <a rel=\"noreferrer noopener\" href=\"${VOCALS}\" target=\"_blank\">vocals</a> ${sheet_links}</p>"
		echo "</details>"
		echo ""
		echo "<details class=\"wp-block-details\"><summary>YouTube</summary>"
		echo "<figure class=\"wp-block-embed is-type-video is-provider-youtube wp-block-embed-youtube wp-embed-aspect-4-3 wp-has-aspect-ratio\"><div class=\"wp-block-embed__wrapper\">"
		echo "<iframe title=\"${YOUTUBE_TITLE}\" width=\"740\" height=\"555\" src=\"${YOUTUBE}?feature=oembed\" frameborder=\"0\" allow=\"accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share\" allowfullscreen></iframe>"
		echo "</div></figure>"
		echo "</details>"
		echo ""
		echo "<hr class=\"wp-block-separator has-alpha-channel-opacity\" />"
		echo ""
	else
		echo "[Deploy PDFs] Copying: No PDFs - exiting"
	fi
	#echo "[Deploy PDFs] Exiting: $d"
	cd ..
done