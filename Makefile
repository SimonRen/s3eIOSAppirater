all: j n i

j:
	./s3eIOSAppirater_android_java.mkb

n:
	./s3eIOSAppirater_android.mkb

i:
	./s3eIOSAppirater_iphone.mkb --ios-version=6.1 --arm

o:
	./s3eIOSAppirater_osx.mkb

s:
	javap -s build_s3eiosappirater_android_java/classes/s3eIOSAppirater
