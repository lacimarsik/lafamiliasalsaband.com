mkdir -p PDFs

for d in `find . -maxdepth 1 -type d \( ! -name . ! -name PDFs \)`
do
	d=${d#"./"}
	echo "[Deploy LYs] Entering: $d"
	cd $d
	if compgen -G "*.ly" > /dev/null; then
		num=`ls *.ly | wc -l | xargs`
		echo "[Deploy LY] Copying: $num LY files to LYs/$d"
		mkdir -p ../LYs/$d
		cp *.ly ../LYs/$d
		echo "[Deploy LYs] HTML for web:"
		for f in *.pdf; do echo "<a target="_blank" href="http://www.lafamiliasalsaband.com/wp-content/uploads/pdfs/$d/$f">$f</a>" ; done
		
	else
		echo "[Deploy LYs] Copying: Nothing to copy"
	fi
	echo "[Deploy LYs] Exiting: $d"
	cd ..
done