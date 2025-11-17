#!/usr/bin/env python3
import re
import subprocess
import textwrap
import sys

# --- 1. Definiciones de Estilo y Color ---

# Mapeo de palabras clave a colores (fondo, borde)
# Basado en tus últimas peticiones
# Mapeo de palabras clave a colores (fondo, borde)
# REORDENADO: Palabras clave específicas van PRIMERO
COLOR_MAP = {
    # Específicos primero
    "loadbalancer": ("#A9CCE3", "#5DADE2"), # Azul Oscuro
    "flavor": ("#FCF3CF", "#F7DC6F"),       # Amarillo
    "router": ("#E8DAEF", "#C39BD3"),       # Morado
    "security": ("#EBF5FB", "#AED6F1"),     # Azul Claro
    "firewall": ("#FADBD8", "#F1948A"),     # Rojo
    "network": ("#D5F5E3", "#58D68D"),      # Verde
    
    # Generales al final
    "vm": ("#FAE5D3", "#E59866"),           # Naranja
    "db": ("#FAE5D3", "#E59866"),           # Naranja
    "web": ("#FAE5D3", "#E59866"),           # Naranja
    "storage": ("#FAE5D3", "#E59866"),      # Naranja
}
# Color por defecto para subgrafos que no coincidan
DEFAULT_COLORS = ("#F9F9F9", "#BBBBBB")

# Estilos globales para un look moderno
GLOBAL_STYLES = textwrap.dedent("""
    layout = "dot";
    splines = "curved";
    nodesep = 0.8;
    ranksep = 1.2;

    /* Estilo para TODAS las cajas (nodos) */
    node [
        shape = "box",
        style = "filled,rounded",
        fontname = "sans-serif",
        fontsize = 10,
        fillcolor = "white", /* <-- Nodos siempre blancos */
        color = "#444444",
        penwidth = 1.5
    ];
    
    /* Estilo para TODAS las flechas (aristas) */
    edge [
        fontname = "sans-serif",
        fontsize = 9,
        color = "#555555",
        arrowsize = 0.7
    ];
    
    /* Estilo por defecto para los contenedores (clusters) */
    graph [
        style = "filled,rounded",
        fontname = "sans-serif",
        fontsize = 12,
        penwidth = 1.5,
        fillcolor = "#F9F9F9", 
        color = "#BBBBBB"
    ];
""")

# --- 2. Funciones de Procesamiento ---

def get_terraform_graph():
    """
    Ejecuta 'terraform graph' y captura su salida (el string DOT).
    """
    print("1. Ejecutando 'terraform graph'...")
    try:
        # Ejecuta el comando, captura la salida, la decodifica como utf-8
        # y comprueba si hay errores.
        result = subprocess.run(
            ['terraform', 'graph'],
            capture_output=True,
            check=True,
            encoding='utf-8'
        )
        
        if "digraph G {" not in result.stdout:
            print("❌ Error: La salida de 'terraform graph' no parece ser un grafo DOT válido.", file=sys.stderr)
            if result.stderr:
                print("Detalles del error:", result.stderr, file=sys.stderr)
            return None
            
        print("   ... 'terraform graph' completado.")
        return result.stdout # Este es el string DOT en crudo
        
    except FileNotFoundError:
        print("❌ Error: Comando 'terraform' no encontrado.", file=sys.stderr)
        print("Asegúrate de que Terraform esté instalado y en el PATH.", file=sys.stderr)
        return None
    except subprocess.CalledProcessError as e:
        print(f"❌ Error al ejecutar 'terraform graph':", file=sys.stderr)
        print("Terraform (stderr):", e.stderr, file=sys.stderr)
        print("Asegúrate de estar en un directorio con un 'init' de Terraform válido.", file=sys.stderr)
        return None


def shorten_node_labels(dot_code):
    """
    Busca [label="..."] y acorta el contenido.
    Ej: "data.openstack_net...ext_network" -> "data.ext_network"
    Ej: "openstack_compute_instance_v2.vm" -> "instance_v2.vm"
    """
    def replacer(match):
        label = match.group(1)
        
        try:
            if label.startswith("data."):
                # "data.provider_...type.name" -> "data.name"
                parts = label.split('.')
                if len(parts) > 2:
                    label = f"data.{parts[-1]}"
            elif label.startswith("openstack_"):
                # "openstack_compute_instance_v2.vm" -> "instance_v2.vm"
                parts = label.split('.')
                if len(parts) == 2:
                    resource_type = parts[0].split('_')
                    if len(resource_type) > 2:
                        # Quita las primeras dos palabras (ej: openstack_compute)
                        new_type = "_".join(resource_type[2:])
                        label = f"{new_type}.{parts[1]}"
                    else:
                        # Quita solo "openstack_"
                        new_type = "_".join(resource_type[1:])
                        label = f"{new_type}.{parts[1]}"
        except Exception:
            pass # Si falla el acortamiento, simplemente usa la etiqueta original
        
        return f'[label="{label}"]'

    return re.sub(r'\[label="([^"]+)"\]', replacer, dot_code)


def inject_global_styles(dot_code):
    """
    Inyecta los estilos globales justo después de la primera llave "{"
    """
    return re.sub(
        r"(digraph\s+G\s*\{)", 
        r"\1\n" + GLOBAL_STYLES + "\n", 
        dot_code, 
        count=1
    )

def colorize_subgraphs(dot_code):
    """
    Busca cada "subgraph" y le inyecta su 'fillcolor' y 'color'
    basándose en el COLOR_MAP.
    """
    def replacer(match):
        subgraph_open_line = match.group(1) # "subgraph "cluster_..." {"
        subgraph_name = match.group(2)      # ""cluster_module.web""
        
        fill, border = DEFAULT_COLORS
        
        for key, (f, b) in COLOR_MAP.items():
            if key in subgraph_name:
                fill, border = f, b
                break 
                
        style_injection = f'\n        fillcolor="{fill}";\n        color="{border}";\n'
        return subgraph_open_line + style_injection

    return re.sub(
        r'(subgraph\s+("cluster_module\.[^"]+")\s*\{)', 
        replacer, 
        dot_code
    )

def generate_png_from_dot(dot_code, output_filename="terraform_graph.png"):
    """
    Ejecuta el comando 'dot' de Graphviz para generar el PNG.
    """
    print(f"5. Generando '{output_filename}' usando 'dot'...")
    try:
        process = subprocess.run(
            ['dot', '-Tpng', '-o', output_filename],
            input=dot_code,
            encoding='utf-8',
            check=True,
            capture_output=True
        )
        print(f"\n✅ ¡Éxito! Se ha generado '{output_filename}'")
    except FileNotFoundError:
        print("❌ Error: Comando 'dot' no encontrado.", file=sys.stderr)
        print("Por favor, asegúrate de que Graphviz esté instalado y en el PATH.", file=sys.stderr)
        print("Puedes descargarlo desde: https://graphviz.org/download/", file=sys.stderr)
    except subprocess.CalledProcessError as e:
        print(f"❌ Error al ejecutar 'dot' de Graphviz:", file=sys.stderr)
        print("DOT (stderr):", e.stderr, file=sys.stderr)

# --- 3. Ejecución Principal ---

def main():
    # Soporta un argumento: 'png' (por defecto) o 'dot'
    mode = 'png'
    if len(sys.argv) > 1:
        arg = sys.argv[1].lower()
        if arg in ('png', 'dot'):
            mode = arg
        else:
            print("Uso: generate_graph.py [png|dot]")
            print("  png - generar imagen PNG (default)")
            print("  dot - guardar la salida DOT cruda de 'terraform graph' en 'terraform_graph_raw.dot'")
            sys.exit(1)

    # 1. Obtener el DOT en crudo de Terraform
    raw_dot_string = get_terraform_graph()

    if not raw_dot_string:
        print("No se pudo generar el grafo. Abortando.", file=sys.stderr)
        sys.exit(1) # Salir con código de error

    # Aplicar transformaciones (labels, estilos, coloreado)
    print("2. Acortando etiquetas de nodos...")
    modified_dot = shorten_node_labels(raw_dot_string)

    print("3. Inyectando estilos globales...")
    modified_dot = inject_global_styles(modified_dot)

    print("4. Coloreando subgrafos por palabra clave...")
    modified_dot = colorize_subgraphs(modified_dot)

    if mode == 'dot':
        # Guardar el DOT ya formateado (lo que se pasaría a dot)
        out_file = 'terraform_graph_styled.dot'
        print(f"Guardando DOT formateado en '{out_file}'...")
        try:
            with open(out_file, 'w', encoding='utf-8') as f:
                f.write(modified_dot)
            print(f"✅ DOT formateado guardado en '{out_file}'")
            sys.exit(0)
        except Exception as e:
            print(f"❌ Error al escribir '{out_file}': {e}", file=sys.stderr)
            sys.exit(1)

    # Si llegamos aquí, mode == 'png' -> generar PNG usando el DOT transformado
    generate_png_from_dot(modified_dot, "terraform_graph.png")

if __name__ == "__main__":
    main()