TARGET = ray

RC = "/c/Program Files (x86)/Windows Kits/10/bin/10.0.26100.0/x64/rc.exe"

all: res

res:
	@#windres -O coff $(TARGET).rc -o $(TARGET)32.res
	@#windres -O coff $(TARGET).rc -o $(TARGET)64.res
	$(RC) $(TARGET).rc
	mv $(TARGET).res $(TARGET)32.res
