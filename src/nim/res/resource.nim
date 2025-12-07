const ResPrefix = "ray"

{.used.}
when defined(vcc):
  {.link: ResPrefix & "Vcc.res".}

elif defined(cpu64):
  {.link: ResPrefix & "64.res".}

else:
  {.link: ResPrefix & "32.res".}
