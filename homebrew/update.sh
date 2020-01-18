#!/bin/sh -e

samples=$(sed -n -e '/<SampleFile/{s/[^>]*>//;s/<.*//;p;}' chapter.xml)

sed -n -e '1,/BEGIN: Samples/p' chapter.xml > .chapter.xml
for sample in $samples; do
	echo "\t\t<SoundSample>" >> .chapter.xml
	echo "\t\t\t<Title>${sample}</Title>" >> .chapter.xml
	echo "\t\t\t<Uuid>${sample}</Uuid>" >> .chapter.xml
	echo "\t\t\t<Extension>ogg</Extension>" >> .chapter.xml
	echo "\t\t</SoundSample>" >> .chapter.xml
done
sed -n -e '/END: Samples/,$p' chapter.xml >> .chapter.xml
mv .chapter.xml chapter.xml

sed -n -e '1,/BEGIN: Samples/p' manifest.xml > .manifest.xml
for sample in $samples; do
	echo "\t\t<SoundsetFile>" >> .manifest.xml
	echo "\t\t\t<Filename>${sample}.ogg</Filename>" >> .manifest.xml
	echo "\t\t\t<Url>https://bard.local/soundscape/${sample}.ogg</Url>" >> .manifest.xml
	echo "\t\t</SoundsetFile>" >> .manifest.xml
done
sed -n -e '/END: Samples/,$p' manifest.xml >> .manifest.xml
mv .manifest.xml manifest.xml