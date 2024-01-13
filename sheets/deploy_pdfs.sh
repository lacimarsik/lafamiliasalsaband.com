mkdir -p PDFs

#echo "[Deploy PDFs] Removing previous PDFs"
rm -rf ./PDFs

for d in `find . -maxdepth 1 -type d \( ! -name . ! -name PDFs ! -name templates ! -name inactive \) | sort -Vr`
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
		sheets_dir="https://github.com/lacimarsik/lafamiliasalsaband.com/blob/main/sheets"
		sheet_links=""
		for instrument in ${instruments[@]}; do sheet_links+="<a rel=\"noreferrer noopener\" href=\"${sheets_dir}/${d}/${songname}_${instrument}.pdf\" target=\"_blank\">${instrument}</a> "; done
		
		#echo "[Deploy PDFs] Creating HTML for web"
		echo ""
		echo "<p class=\"has-vivid-red-color has-text-color\"><strong>#${ID} ${TITLE} (${INTERPRET})</strong></p>"
	    echo ""
	    echo "<details class=\"wp-block-details ${TEMPOCLASS} has-text-color\"><summary>Instructions: ${TEMPO}</summary>"
		echo "<p class=\"has-cyan-bluish-gray-color has-text-color\">${INSTRUCTIONS}</p>"
		echo "</details>"
		echo ""
		echo "<details class=\"wp-block-details\"><summary>Resources</summary>"
		echo "<p><a rel=\"noreferrer noopener\" href=\"${MP3}\" target=\"_blank\">mp3</a> <a rel=\"noreferrer noopener\" href=\"${TEXT}\" target=\"_blank\">text</a> <a rel=\"noreferrer noopener\" href=\"${CHORD}\" target=\"_blank\">chord</a> ${sheet_links}</p>"
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