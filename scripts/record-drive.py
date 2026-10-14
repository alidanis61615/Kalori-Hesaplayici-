import subprocess,sys
from pathlib import Path

output=Path('docs/media');output.mkdir(parents=True,exist_ok=True)
video_log=(output/'video-recorder.log').open('w')
command=['flutter','drive','--driver=test_driver/integration_test.dart','--target=integration_test/portfolio_test.dart','--use-application-binary=build/app/outputs/flutter-apk/app-debug.apk','--keep-app-running','-d','emulator-5554']
driver=subprocess.Popen(command,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,bufsize=1)
recording=None
stopped=False
def stop():
 global stopped
 if recording is None or stopped:return
 subprocess.run(['adb','shell','killall','-INT','screenrecord'],check=False)
 try:recording.wait(timeout=20)
 except subprocess.TimeoutExpired:recording.terminate();recording.wait(timeout=5)
 stopped=True
try:
 for line in driver.stdout:
  print(line,end='',flush=True)
  if 'PORTFOLIO_VIDEO_START' in line and recording is None:
   recording=subprocess.Popen(['adb','shell','screenrecord','--size','540x1200','--time-limit','120','--bit-rate','2000000','/sdcard/portfolio-demo.mp4'],stdout=video_log,stderr=subprocess.STDOUT)
  if 'PORTFOLIO_VIDEO_END' in line:stop()
 code=driver.wait()
finally:
 stop();video_log.close()
if code:sys.exit(code)
if recording is None:raise RuntimeError('Application did not emit the recording-start marker')
print('Android video recording complete; recorder exit:',recording.returncode)
