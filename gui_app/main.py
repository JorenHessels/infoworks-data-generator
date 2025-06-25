import os
import tkinter as tk
from tkinter import ttk
from file_parser import FileParser

def name_to_id(paths, name):
    for p in paths:
        if p.short == name:
            return p.id
        
def run_simulation(network_id, rainfall_id, roughness_type, roughness_value, weir_coefficient, initial_infiltration):
    print(f"Attempting N:{network_id} RFID:{rainfall_id} RT:{roughness_type} RV:{roughness_value} WDC:{weir_coefficient} II:{initial_infiltration}")
    os.system(f"generator.bat {network_id} {rainfall_id} {roughness_type} {roughness_value} {weir_coefficient} {initial_infiltration}")

def linspace(min, max, steps):
    if steps <= 1:
        return [min]
    step = (max - min) / (steps - 1)
    return [min + i * step for i in range(steps)]

def get_values_from_tuple(tuple):
    min = float(tuple[0])
    max = float(tuple[1])
    steps = int(tuple[2])

    if min==max or steps == 0:
        values = [min]
    else:
        values = linspace(min, max, steps)
    return values


def submit():
    selected_network = network_var.get()
    n_id = name_to_id(networks, selected_network)
    selected_rainfalls = [str(id) for id, var in rainfall_vars.items() if var.get()]
    selected_roughness_type = roughness_type_var.get()
    r_type = selected_roughness_type[0].lower()

    roughness = (roughness_min.get(), roughness_max.get(), roughness_steps.get())
    weir = (weir_min.get(), weir_max.get(), weir_steps.get())
    infiltration = (infil_min.get(), infil_max.get(), infil_steps.get())

    roughness_values = get_values_from_tuple(roughness)
    weir_values = get_values_from_tuple(weir)
    infiltration_values = get_values_from_tuple(infiltration)

    root.destroy()

    for rf in selected_rainfalls:
        for r in roughness_values:
            for w in weir_values:
                for i in infiltration_values:
                    run_simulation(n_id, rf, r_type, r, w, i)

# Extracting Network and Rainfalls from database.
path = os.getcwd() + "\\gui_app"
if not os.path.exists(f'{path}\\networks.txt') or not os.path.exists(f'{path}\\networks.txt'):
    os.system('init.bat')

network_parser = FileParser(f'{path}\\networks.txt')
network_parser.parse()
networks = network_parser.get_entries()

rainfall_parser = FileParser(f'{path}\\rainfalls.txt')
rainfall_parser.parse()
rainfalls = rainfall_parser.get_entries()

# TODO: Add network exporting
path = os.getcwd() + "\\generated_data\\network_exports"
if len(os.listdir(path)) == 0:
    for n in networks:
        os.system(f"export_graph.bat {n.id}")

# GUI
root = tk.Tk()
root.title("Simulation Runner Configurator")
root.geometry("800x600")
root.resizable(True, True)

padding = {'padx': 10, 'pady': 5}

# --- Network Selection ---
tk.Label(root, text="Select Network:").grid(row=0, column=0, sticky="w", **padding)
network_var = tk.StringVar()
network_dropdown = ttk.Combobox(root, textvariable=network_var, state="readonly")
network_dropdown['values'] = [n.short for n in networks]
network_dropdown.grid(row=0, column=1, sticky="ew", **padding)

# --- Rainfall Selection with LabelFrame & Scroll ---
rainfall_frame = ttk.LabelFrame(root, text="Select Rainfall(s):")
rainfall_frame.grid(row=1, column=0, columnspan=2, sticky="nsew", **padding)
rainfall_frame.grid_columnconfigure(0, weight=1)

select_all_var = tk.BooleanVar()
def toggle_all():
    for var in rainfall_vars.values():
        var.set(select_all_var.get())

select_all_chk = tk.Checkbutton(rainfall_frame, text="Select All", variable=select_all_var, command=toggle_all)
select_all_chk.pack(anchor="w", padx=5, pady=(5, 0))

frame_container = tk.Frame(rainfall_frame)
frame_container.pack(fill="both", expand=True, padx=5, pady=5)

canvas = tk.Canvas(frame_container, highlightthickness=0)
scrollbar = ttk.Scrollbar(frame_container, orient="vertical", command=canvas.yview)
checkbox_frame = tk.Frame(canvas)
canvas_frame_id = canvas.create_window((0, 0), window=checkbox_frame, anchor="nw")

canvas.configure(yscrollcommand=scrollbar.set)
canvas.pack(side="left", fill="both", expand=True)
scrollbar.pack(side="right", fill="y")

checkbox_frame.bind("<Configure>", lambda e: canvas.configure(scrollregion=canvas.bbox("all")))
canvas.bind("<Configure>", lambda e: canvas.itemconfig(canvas_frame_id, width=e.width))
canvas.bind_all("<MouseWheel>", lambda e: canvas.yview_scroll(int(-1 * (e.delta / 120)), "units"))

rainfall_vars = {}
for i, rf in enumerate(rainfalls):
    var = tk.BooleanVar()
    chk = tk.Checkbutton(checkbox_frame, text=rf.short, variable=var)
    chk.grid(row=i, column=0, sticky="w")
    rainfall_vars[rf.id] = var

# --- Roughness Type Selection ---
tk.Label(root, text="Select Roughness Type:").grid(row=2, column=0, sticky="w", **padding)
roughness_type_var = tk.StringVar()
roughness_dropdown = ttk.Combobox(root, textvariable=roughness_type_var, state="readonly")
roughness_dropdown['values'] = ("CW", "HW", "MANNING", "N")
roughness_dropdown.grid(row=2, column=1, sticky="ew", **padding)

# --- Range Input Helper ---
def add_range_input(label, row, var_min, var_max, var_steps):
    tk.Label(root, text=label).grid(row=row, column=0, sticky="w", **padding)
    frame = tk.Frame(root)
    frame.grid(row=row, column=1, sticky="ew", **padding)
    frame.grid_columnconfigure(0, weight=1)
    frame.grid_columnconfigure(2, weight=1)
    frame.grid_columnconfigure(4, weight=1)

    tk.Entry(frame, textvariable=var_min).grid(row=0, column=0, sticky="ew", padx=(0, 5))
    tk.Label(frame, text="to").grid(row=0, column=1)
    tk.Entry(frame, textvariable=var_max).grid(row=0, column=2, sticky="ew", padx=(5, 20))
    tk.Label(frame, text="steps").grid(row=0, column=3)
    tk.Entry(frame, textvariable=var_steps, width=6).grid(row=0, column=4, sticky="ew", padx=(5, 0))

# --- Range Input Fields ---
roughness_min = tk.StringVar()
roughness_max = tk.StringVar()
roughness_steps = tk.StringVar()

weir_min = tk.StringVar()
weir_max = tk.StringVar()
weir_steps = tk.StringVar()

infil_min = tk.StringVar()
infil_max = tk.StringVar()
infil_steps = tk.StringVar()

add_range_input("Roughness Value:", 3, roughness_min, roughness_max, roughness_steps)
add_range_input("Weir Coefficient:", 4, weir_min, weir_max, weir_steps)
add_range_input("Initial Infiltration:", 5, infil_min, infil_max, infil_steps)

# --- Save Button ---
submit_button = tk.Button(root, text="Save Configuration", width=20, command=submit)
submit_button.grid(row=6, column=0, columnspan=2, pady=15)

# --- Resizability ---
root.grid_columnconfigure(1, weight=1)
root.grid_rowconfigure(1, weight=1)

root.mainloop()
