// Taken from the osdev wiki and later converted to volt code.
module metal;


extern(C) void metal_main(int magic, void* meminfo)
{
	terminal_initialize();

	terminal_writestring("Volt Metal");
	terminal_newline();

	terminal_writestring("Magic: ");
	terminal_hex(magic);
	terminal_newline();

	terminal_writestring("Meninfo: ");
	terminal_hex(cast(int)meminfo);
	terminal_newline();
}

/* Hardware text mode color constants. */
enum vga_color {
	BLACK = 0,
	BLUE = 1,
	GREEN = 2,
	CYAN = 3,
	RED = 4,
	MAGENTA = 5,
	BROWN = 6,
	LIGHT_GREY = 7,
	DARK_GREY = 8,
	LIGHT_BLUE = 9,
	LIGHT_GREEN = 10,
	LIGHT_CYAN = 11,
	LIGHT_RED = 12,
	LIGHT_MAGENTA = 13,
	LIGHT_BROWN = 14,
	WHITE = 15,
};

ubyte vga_make_color(vga_color fg, vga_color bg) {
	return cast(ubyte)(fg | bg << 4);
}

ushort vga_make_entry(char c, ubyte color) {
	ushort c16 = c;
	ushort color16 = color;
	return cast(ushort)(c16 | color16 << 8);
}

enum size_t VGA_WIDTH = 80;
enum size_t VGA_HEIGHT = 25;

global size_t terminal_row;
global size_t terminal_column;
global ubyte terminal_color;
global ushort* terminal_buffer;

void terminal_initialize()
{
	terminal_row = 0;
	terminal_column = 0;
	terminal_color = vga_make_color(vga_color.LIGHT_GREY, vga_color.BLACK);
	terminal_buffer = cast(ushort*) 0xB8000;
	ushort entry = vga_make_entry(' ', terminal_color);

	foreach (y; 0 .. VGA_HEIGHT) {
		foreach (x; 0 .. VGA_WIDTH) {
			const size_t index = y * VGA_WIDTH + x;
			terminal_buffer[index] = entry;
		}
	}
}

void terminal_setcolor(ubyte color)
{
	terminal_color = color;
}

void terminal_putentryat(char c, ubyte color, size_t x, size_t y)
{
	const size_t index = y * VGA_WIDTH + x;
	terminal_buffer[index] = vga_make_entry(c, color);
}

void terminal_putchar(char c)
{
	terminal_putentryat(c, terminal_color, terminal_column, terminal_row);
	if (++terminal_column == VGA_WIDTH) {
		terminal_column = 0;
		if (++terminal_row == VGA_HEIGHT) {
			terminal_row = 0;
		}
	}
}

void terminal_writestring(scope const(char)[] data)
{
	foreach (char d; data) {
		terminal_putchar(d);
	}
}

void terminal_newline()
{
	if (++terminal_row == VGA_HEIGHT) {
		terminal_row = 0;
	}
	terminal_column = 0;
}

void terminal_hex(int hex)
{
	foreach (i; 0 .. 8) {
		int v = (hex >> 28) & 0x0f;
		if (v < 10) {
			terminal_putchar(cast(char)(v + '0'));
		} else {
			terminal_putchar(cast(char)((v - 10) + 'A'));
		}
		hex = hex << 4;
	}
}
