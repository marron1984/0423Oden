#!/bin/bash
set -e

FONT="/usr/share/fonts/opentype/ipafont-gothic/ipag.ttf"
W=1080
H=1920
FPS=30

make_scene() {
  local src="$1" dur="$2" tfile="$3" out="$4" ty="${5:-1450}"
  ffmpeg -y -loop 1 -t "$dur" -i "$src" \
    -vf "split=2[a][b];
         [a]scale=${W}:${H}:force_original_aspect_ratio=increase,crop=${W}:${H},gblur=sigma=30,eq=brightness=-0.25[bg];
         [b]scale=-1:1400:force_original_aspect_ratio=decrease[fg];
         [bg][fg]overlay=(W-w)/2:(H-h)/2-120,
         drawbox=y=${ty}-30:x=60:w=${W}-120:h=320:color=black@0.55:t=fill,
         drawtext=fontfile='${FONT}':textfile='${tfile}':fontcolor=white:fontsize=78:line_spacing=26:x=(w-text_w)/2:y=${ty}:bordercolor=black:borderw=3" \
    -t "$dur" -r "$FPS" -pix_fmt yuv420p -c:v libx264 -preset medium -crf 20 \
    "$out" 2>&1 | tail -1
}

make_final() {
  local dur="$1" out="$2"
  ffmpeg -y -f lavfi -i "color=c=0x1a1a1a:s=${W}x${H}:d=${dur}:r=${FPS}" \
    -vf "drawbox=y=120:x=0:w=${W}:h=4:color=0xc9a96a:t=fill,
         drawbox=y=${H}-124:x=0:w=${W}:h=4:color=0xc9a96a:t=fill,
         drawtext=fontfile='${FONT}':text='この春限り。':fontcolor=0xc9a96a:fontsize=72:x=(w-text_w)/2:y=380,
         drawtext=fontfile='${FONT}':text='おでん屋の麻婆。':fontcolor=white:fontsize=96:x=(w-text_w)/2:y=490,
         drawtext=fontfile='${FONT}':textfile=/tmp/vid/t_final.txt:fontcolor=white:fontsize=52:line_spacing=28:x=(w-text_w)/2:y=800,
         drawtext=fontfile='${FONT}':text='ご予約・お問合せ':fontcolor=white:fontsize=44:x=(w-text_w)/2:y=1260,
         drawtext=fontfile='${FONT}':text='06-6743-4501':fontcolor=0xc9a96a:fontsize=96:x=(w-text_w)/2:y=1340" \
    -pix_fmt yuv420p -c:v libx264 -preset medium -crf 20 \
    "$out" 2>&1 | tail -1
}

cat > /tmp/vid/t1.txt <<'TXT'
おでん屋の麻婆、
まもなく終わります。
TXT
cat > /tmp/vid/t2.txt <<'TXT'
麻婆豆腐定食
出汁が効く、春限りの一皿
TXT
cat > /tmp/vid/t3.txt <<'TXT'
チーズ麻婆
しびれる辛さと、とろけるコク
TXT
cat > /tmp/vid/t4.txt <<'TXT'
土鍋で、熱々のまま。
TXT
cat > /tmp/vid/t5.txt <<'TXT'
他にも、自慢の定食。
ランチ平均 1,000円
TXT
cat > /tmp/vid/t_final.txt <<'TXT'
おでん×スタンド 三徳六味
EST フードホール店
大阪・梅田／11:00〜23:00
TXT

echo "S1"; make_scene /tmp/vid/s1.jpg 3 /tmp/vid/t1.txt /tmp/vid/c1.mp4 1450
echo "S2"; make_scene /tmp/vid/s2.jpg 3 /tmp/vid/t2.txt /tmp/vid/c2.mp4 1500
echo "S3"; make_scene /tmp/vid/s3.jpg 3 /tmp/vid/t3.txt /tmp/vid/c3.mp4 1500
echo "S4"; make_scene /tmp/vid/s4.jpg 3 /tmp/vid/t4.txt /tmp/vid/c4.mp4 1550
echo "S5"; make_scene /tmp/vid/s5.jpg 3 /tmp/vid/t5.txt /tmp/vid/c5.mp4 1500
echo "S6"; make_final 4 /tmp/vid/c6.mp4

cat > /tmp/vid/concat.txt <<EOF
file '/tmp/vid/c1.mp4'
file '/tmp/vid/c2.mp4'
file '/tmp/vid/c3.mp4'
file '/tmp/vid/c4.mp4'
file '/tmp/vid/c5.mp4'
file '/tmp/vid/c6.mp4'
EOF

ffmpeg -y -f concat -safe 0 -i /tmp/vid/concat.txt -c copy /tmp/vid/reel.mp4 2>&1 | tail -1
ls -la /tmp/vid/reel.mp4
ffprobe -v error -show_entries format=duration,size -of default=nw=1 /tmp/vid/reel.mp4
