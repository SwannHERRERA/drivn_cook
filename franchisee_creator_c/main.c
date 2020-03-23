#include <stdio.h>
#include <stdlib.h>
#include <gtk-3.0/gtk/gtk.h>

int main(int argc, char **argv) {
    GtkBuilder      *builder; 
    GtkWidget       *window;

    gtk_init(&argc, &argv);

    builder = gtk_builder_new();
    gtk_builder_add_from_file (builder, "assets/glade/main.glade", NULL);

    window = GTK_WIDGET(gtk_builder_get_object(builder, "main_windows"));
    gtk_builder_connect_signals(builder, NULL);

    g_object_unref(builder);

    gtk_widget_show(window);                
    gtk_main();

    return EXIT_SUCCESS;
}

// called when window is closed
void on_main_windows_destroy()
{
    gtk_main_quit();
}