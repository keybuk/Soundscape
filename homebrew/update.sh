#!/bin/sh -e

for chapter_file in chapter_*.xml; do
	chapter=${chapter_file#chapter_}
	chapter=${chapter%.xml}

	echo Updating ${chapter}
	samples=$(sed -n -e '/<SampleFile/{s/[^>]*>//;s/<.*//;p;}' chapter_${chapter}.xml)

	sed -n -e '1,/BEGIN: Samples/p' chapter_${chapter}.xml > .chapter_${chapter}.xml
	for sample in $samples; do
		echo "\t\t<SoundSample>" >> .chapter_${chapter}.xml
		echo "\t\t\t<Title>${sample}</Title>" >> .chapter_${chapter}.xml
		echo "\t\t\t<Uuid>${sample}</Uuid>" >> .chapter_${chapter}.xml
		echo "\t\t\t<Extension>ogg</Extension>" >> .chapter_${chapter}.xml
		echo "\t\t</SoundSample>" >> .chapter_${chapter}.xml
	done
	sed -n -e '/END: Samples/,$p' chapter_${chapter}.xml >> .chapter_${chapter}.xml
	mv .chapter_${chapter}.xml chapter_${chapter}.xml

	sed -n -e '1,/BEGIN: Samples/p' manifest_${chapter}.xml > .manifest_${chapter}.xml
	for sample in $samples; do
		echo "\t\t<SoundsetFile>" >> .manifest_${chapter}.xml
		echo "\t\t\t<Filename>${sample}.ogg</Filename>" >> .manifest_${chapter}.xml
		echo "\t\t\t<Url>https://bard.local/soundscape/${sample}.ogg</Url>" >> .manifest_${chapter}.xml
		echo "\t\t</SoundsetFile>" >> .manifest_${chapter}.xml
	done
	sed -n -e '/END: Samples/,$p' manifest_${chapter}.xml >> .manifest_${chapter}.xml
	mv .manifest_${chapter}.xml manifest_${chapter}.xml
done
