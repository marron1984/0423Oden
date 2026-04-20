#!/bin/bash
set -e

FB="/tmp/fonts/NotoSansJP-Bold.otf"
FK="/tmp/fonts/NotoSansJP-Black.otf"
FM="/tmp/fonts/NotoSansJP-Medium.otf"
G="0xc9a96a"
W=1080; H=1920; FPS=30
V=/tmp/vid
BGM="/home/user/0423Oden/Velocity_of_Rain.mp3"

make_scene() {
  local src="$1" dur="$2" sub="$3" m1="$4" m2="$5" out="$6"
  local fo=$(awk "BEGIN{print ${dur}-0.35}")
  local FC="[0:v]split=2[a][b];[a]scale=${W}:${H}:force_original_aspect_ratio=increase,crop=${W}:${H},gblur=sigma=32,eq=brightness=-0.32:saturation=0.85[bg];[b]scale=-1:1280:force_original_aspect_ratio=decrease[fg];[bg][fg]overlay=(W-w)/2:(H-h)/2-180[base];[base]drawbox=y=1480:x=0:w=${W}:h=${H}-1480:color=black@0.58:t=fill,drawbox=y=1540:x=100:w=4:h='if(lt(t\,0.6)\,t/0.6*260\,260)':color=${G}:t=fill,drawtext=fontfile=${FM}:text='${sub}':fontcolor=${G}:alpha='if(lt(t\,0.3)\,0\,if(lt(t\,0.8)\,(t-0.3)/0.5\,1))':fontsize=40:x=140:y=1555,drawtext=fontfile=${FK}:text='${m1}':fontcolor=white:alpha='if(lt(t\,0.6)\,0\,if(lt(t\,1.2)\,(t-0.6)/0.6\,1))':fontsize=86:x=140:y='1630+40*(1-min(1\,max(0\,(t-0.6)/0.6)))',drawtext=fontfile=${FK}:text='${m2}':fontcolor=white:alpha='if(lt(t\,0.85)\,0\,if(lt(t\,1.45)\,(t-0.85)/0.6\,1))':fontsize=86:x=140:y='1730+40*(1-min(1\,max(0\,(t-0.85)/0.6)))',fade=t=in:st=0:d=0.4,fade=t=out:st=${fo}:d=0.35"
  ffmpeg -y -loop 1 -t "$dur" -i "$src" -filter_complex "$FC" -r "$FPS" -pix_fmt yuv420p -c:v libx264 -preset medium -crf 20 "$out" 2>&1 | tail -2
}

make_final() {
  local dur="$1" out="$2"
  local FC="[0:v]format=yuv420p,drawbox=y=160:x=420:w='if(lt(t\,0.8)\,t/0.8*240\,240)':h=2:color=${G}:t=fill,drawbox=y=1758:x=420:w='if(lt(t\,0.8)\,t/0.8*240\,240)':h=2:color=${G}:t=fill,drawtext=fontfile=${FM}:text='Spring Only':fontcolor=${G}:alpha='if(lt(t\,0.4)\,0\,if(lt(t\,1)\,(t-0.4)/0.6\,1))':fontsize=40:x=(w-text_w)/2:y=420,drawtext=fontfile=${FK}:text='この春限り。':fontcolor=white:alpha='if(lt(t\,0.7)\,0\,if(lt(t\,1.3)\,(t-0.7)/0.6\,1))':fontsize=72:x=(w-text_w)/2:y=500,drawtext=fontfile=${FK}:text='おでん屋の麻婆。':fontcolor=white:alpha='if(lt(t\,1)\,0\,if(lt(t\,1.6)\,(t-1)/0.6\,1))':fontsize=102:x=(w-text_w)/2:y=600,drawtext=fontfile=${FB}:text='おでん×スタンド 三徳六味':fontcolor=white:alpha='if(lt(t\,1.4)\,0\,if(lt(t\,2)\,(t-1.4)/0.6\,1))':fontsize=48:x=(w-text_w)/2:y=900,drawtext=fontfile=${FM}:text='EST フードホール店':fontcolor=0xcccccc:alpha='if(lt(t\,1.55)\,0\,if(lt(t\,2.15)\,(t-1.55)/0.6\,1))':fontsize=42:x=(w-text_w)/2:y=970,drawtext=fontfile=${FM}:text='大阪・梅田  /  11\\:00 ー 23\\:00':fontcolor=0xaaaaaa:alpha='if(lt(t\,1.7)\,0\,if(lt(t\,2.3)\,(t-1.7)/0.6\,1))':fontsize=38:x=(w-text_w)/2:y=1040,drawtext=fontfile=${FM}:text='RESERVATION':fontcolor=${G}:alpha='if(lt(t\,2.1)\,0\,if(lt(t\,2.7)\,(t-2.1)/0.6\,1))':fontsize=36:x=(w-text_w)/2:y=1300,drawtext=fontfile=${FK}:text='06-6743-4501':fontcolor=white:alpha='if(lt(t\,2.3)\,0\,if(lt(t\,2.9)\,(t-2.3)/0.6\,1))':fontsize=104:x=(w-text_w)/2:y=1380,fade=t=in:st=0:d=0.5"
  ffmpeg -y -f lavfi -i "color=c=0x141414:s=${W}x${H}:d=${dur}:r=${FPS}" -filter_complex "$FC" -pix_fmt yuv420p -c:v libx264 -preset medium -crf 20 "$out" 2>&1 | tail -2
}

echo "S1"; make_scene ${V}/s1.jpg 3 "Spring Only" "おでん屋の麻婆、" "まもなく終わります。" ${V}/c1.mp4
echo "S2"; make_scene ${V}/s2.jpg 3 "Lunch / 01"  "麻婆豆腐定食"     "春限りの一皿"       ${V}/c2.mp4
echo "S3"; make_scene ${V}/s3.jpg 3 "Lunch / 02"  "チーズ麻婆"       "伸びる、とろける。" ${V}/c3.mp4
echo "S4"; make_scene ${V}/s4.jpg 3 "Style"       "土鍋で、"         "熱々のまま。"       ${V}/c4.mp4
echo "S5"; make_scene ${V}/s5.jpg 3 "Daily"       "自慢の定食。"     "平均 1,000円"       ${V}/c5.mp4
echo "SF"; make_final 5 ${V}/c6.mp4

cat > ${V}/concat.txt <<EOF
file '${V}/c1.mp4'
file '${V}/c2.mp4'
file '${V}/c3.mp4'
file '${V}/c4.mp4'
file '${V}/c5.mp4'
file '${V}/c6.mp4'
EOF

ffmpeg -y -f concat -safe 0 -i ${V}/concat.txt -c copy ${V}/reel_noaudio.mp4 2>&1 | tail -1

DUR=$(ffprobe -v error -show_entries format=duration -of default=nw=1:nk=1 ${V}/reel_noaudio.mp4)
FO=$(awk "BEGIN{print ${DUR}-1.2}")
echo "Video duration: ${DUR}  | fade-out start: ${FO}"

ffmpeg -y -i ${V}/reel_noaudio.mp4 -i "${BGM}" -filter_complex "[1:a]atrim=0:${DUR},asetpts=PTS-STARTPTS,volume=0.55,afade=t=in:st=0:d=0.6,afade=t=out:st=${FO}:d=1.2[aout]" -map 0:v -map "[aout]" -c:v copy -c:a aac -b:a 192k -shortest ${V}/reel.mp4 2>&1 | tail -1

ls -la ${V}/reel.mp4
ffprobe -v error -show_entries format=duration,size -show_entries stream=codec_type -of default=nw=1 ${V}/reel.mp4
