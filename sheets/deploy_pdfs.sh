mkdir -p PDFs

for d in `find . -maxdepth 1 -type d \( ! -name . ! -name PDFs \)`
do
	d=${d#"./"}
	echo "[Deploy PDFs] Entering: $d"
	cd $d
	if compgen -G "*.pdf" > /dev/null; then
		num=`ls *.pdf | wc -l | xargs`
		echo "[Deploy PDFs] Copying: $num PDF files to PDFs/$d"
		mkdir -p ../PDFs/$d
		cp *.pdf ../PDFs/$d
	else
		echo "[Deploy PDFs] Copying: Nothing to copy"
	fi
	echo "[Deploy PDFs] Exiting: $d"
	cd ..
done