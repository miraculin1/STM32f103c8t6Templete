Based on the standard peripheral lib v3.6.0

This is a templete for STM32f103c8t6 MCU.  
_tested in manjaro_

# Requires

- `arm-none-eabi-gcc`
- `make`
- `stlink`

# Notice

the file `stm32f103c8x.ld` is from [link](https://github.com/Palmitoxico/STM32F103C8T6-Examples/blob/master/SerialPort/Makefile).
Later I would look into the ld file.
AND I'll fork it.

I found that in the CubeMX generated project there is a ld file,
pretty good to use.

the startup file is from the truestudio folder.Can use
`st-info --probe` to decide use md, hd or xl etc.
