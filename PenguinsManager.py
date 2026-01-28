#!/usr/bin/env python3
"""
Penguins! Game Manager - Steam Deck Edition
"""

import tkinter as tk
from tkinter import messagebox, simpledialog
import subprocess
import shutil
from pathlib import Path


class PenguinsManager:
    # Colors
    BG_DARK = '#0f0f1a'
    BG_PANEL = '#1a1a2e'
    BG_BUTTON = '#16213e'
    BG_BUTTON_HOVER = '#1f2b47'
    BG_GREEN = '#0d7a3e'
    BG_GREEN_HOVER = '#0f8f48'
    BG_RED = '#6b1a1a'
    CYAN = '#00d4ff'
    WHITE = '#ffffff'
    GRAY = '#888888'
    DARK_GRAY = '#444444'

    def __init__(self):
        self.game_dir = Path(__file__).parent.resolve()
        self.profile_dir = self.game_dir / "prefix/pfx/drive_c/ProgramData/WildTangent/penguins/Persistent/resources/profiles"

        self.root = tk.Tk()
        self.root.title("Penguins!")

        # Full width, reasonable height for Steam Deck
        self.root.geometry("800x480")
        self.root.configure(bg=self.BG_DARK)
        self.root.resizable(False, False)

        # Center window
        self.root.update_idletasks()
        x = (self.root.winfo_screenwidth() - 800) // 2
        y = (self.root.winfo_screenheight() - 480) // 2
        self.root.geometry(f"800x480+{x}+{y}")

        self.create_ui()

    def get_profile_name(self, profile_num):
        """Extract username from binary profile file"""
        profile_path = self.profile_dir / f"profile{profile_num}.dat"
        if not profile_path.exists():
            return None
        try:
            data = profile_path.read_bytes()
            # Username is stored after pattern: 05 04 00 <length> <string>
            # Field 05 = Name field, followed by type info, then length-prefixed string
            for i in range(len(data) - 10):
                if data[i:i+3] == b'\x05\x04\x00':
                    length = data[i+3]
                    if 1 <= length <= 30:
                        name_bytes = data[i+4:i+4+length]
                        # Remove null bytes and decode
                        name = name_bytes.rstrip(b'\x00').decode('latin-1', errors='ignore').strip()
                        if name and len(name) >= 1:
                            return name
            return f"Profile {profile_num + 1}"
        except:
            return f"Profile {profile_num + 1}"

    def get_pending_name(self, profile_num):
        """Check for pending username from previous setup"""
        pending = self.game_dir / f".pending_username_{profile_num}"
        if pending.exists():
            return pending.read_text().strip()
        return None

    def create_profile(self, profile_num, username):
        """Create a new profile by copying template and patching username"""
        template = self.game_dir / "prefix/pfx/drive_c/Program Files (x86)/WildGames/Penguins!/default_profile.dat"
        profile_path = self.profile_dir / f"profile{profile_num}.dat"

        if not template.exists():
            return False, "Template not found"

        try:
            # Read template
            data = bytearray(template.read_bytes())

            # Find username location: pattern 05 04 00 <len> <name>
            for i in range(len(data) - 10):
                if data[i:i+3] == b'\x05\x04\x00':
                    # Found it - patch in new username
                    old_len = data[i+3]

                    # Encode new username (max ~20 chars to be safe)
                    new_name = username[:20].encode('latin-1')
                    new_len = len(new_name) + 1  # +1 for space/padding

                    # Build new data: before + 05 04 00 + len + name + space + after
                    before = data[:i+3]
                    after = data[i+4+old_len:]

                    new_data = before + bytes([new_len]) + new_name + b' ' + after

                    # Ensure profile dir exists
                    self.profile_dir.mkdir(parents=True, exist_ok=True)

                    # Write new profile with same permissions as template
                    profile_path.write_bytes(new_data)
                    profile_path.chmod(0o755)

                    # Clean up pending file if exists
                    pending = self.game_dir / f".pending_username_{profile_num}"
                    if pending.exists():
                        pending.unlink()

                    return True, f"Profile '{username}' created"

            return False, "Could not find username location in template"
        except Exception as e:
            return False, str(e)

    def rename_profile(self, profile_num, new_name):
        """Rename an existing profile by patching the username"""
        profile_path = self.profile_dir / f"profile{profile_num}.dat"
        if not profile_path.exists():
            return False

        try:
            data = bytearray(profile_path.read_bytes())

            # Find username location: pattern 05 04 00 <len> <name>
            for i in range(len(data) - 10):
                if data[i:i+3] == b'\x05\x04\x00':
                    old_len = data[i+3]

                    # Encode new username
                    new_name_bytes = new_name[:20].encode('latin-1')
                    new_len = len(new_name_bytes) + 1

                    # Build new data
                    before = data[:i+3]
                    after = data[i+4+old_len:]
                    new_data = before + bytes([new_len]) + new_name_bytes + b' ' + after

                    profile_path.write_bytes(new_data)
                    profile_path.chmod(0o755)
                    return True

            return False
        except:
            return False

    def create_ui(self):
        # Left panel - branding and launch
        left_panel = tk.Frame(self.root, bg=self.BG_PANEL, width=350)
        left_panel.pack(side=tk.LEFT, fill=tk.Y)
        left_panel.pack_propagate(False)

        # Spacer
        tk.Frame(left_panel, bg=self.BG_PANEL, height=40).pack()

        # Title
        tk.Label(left_panel, text="PENGUINS!", font=('Arial Black', 32),
                fg=self.CYAN, bg=self.BG_PANEL).pack(pady=(20, 5))

        tk.Label(left_panel, text="Steam Deck Edition", font=('Arial', 11),
                fg=self.GRAY, bg=self.BG_PANEL).pack()

        tk.Label(left_panel, text="by deucebucket", font=('Arial', 9),
                fg=self.DARK_GRAY, bg=self.BG_PANEL).pack(pady=(2, 30))

        # Launch button
        launch_frame = tk.Frame(left_panel, bg=self.BG_PANEL)
        launch_frame.pack(pady=20)

        self.launch_btn = tk.Button(launch_frame, text="LAUNCH GAME",
                                   font=('Arial Black', 14),
                                   bg=self.BG_GREEN, fg=self.WHITE,
                                   activebackground=self.BG_GREEN_HOVER,
                                   activeforeground=self.WHITE,
                                   relief=tk.FLAT, bd=0, cursor='hand2',
                                   width=18, height=2,
                                   command=self.launch_game)
        self.launch_btn.pack()

        # Bottom buttons
        bottom_frame = tk.Frame(left_panel, bg=self.BG_PANEL)
        bottom_frame.pack(side=tk.BOTTOM, pady=20)

        for text, cmd in [("Updates", self.check_updates),
                          ("Repair", self.repair_install),
                          ("Exit", self.root.quit)]:
            btn = tk.Button(bottom_frame, text=text, font=('Arial', 10),
                           bg=self.BG_BUTTON, fg=self.WHITE,
                           activebackground=self.BG_BUTTON_HOVER,
                           relief=tk.FLAT, width=8, cursor='hand2',
                           command=cmd)
            btn.pack(side=tk.LEFT, padx=5)

        # Status
        self.status_var = tk.StringVar(value="Ready")
        tk.Label(left_panel, textvariable=self.status_var, font=('Arial', 9),
                fg=self.DARK_GRAY, bg=self.BG_PANEL).pack(side=tk.BOTTOM, pady=5)

        # Right panel - profiles
        right_panel = tk.Frame(self.root, bg=self.BG_DARK)
        right_panel.pack(side=tk.RIGHT, fill=tk.BOTH, expand=True)

        tk.Label(right_panel, text="USER PROFILES", font=('Arial Bold', 12),
                fg=self.GRAY, bg=self.BG_DARK).pack(pady=(30, 20))

        # Profile cards
        self.profile_frames = []
        self.profile_name_labels = []
        self.profile_status_labels = []

        profiles_container = tk.Frame(right_panel, bg=self.BG_DARK)
        profiles_container.pack(expand=True)

        for i in range(4):
            row, col = i // 2, i % 2

            card = tk.Frame(profiles_container, bg=self.BG_PANEL,
                           relief=tk.FLAT, bd=0)
            card.grid(row=row, column=col, padx=12, pady=12, sticky='nsew')

            # Make it clickable
            card.bind('<Button-1>', lambda e, x=i: self.manage_profile(x))
            card.configure(cursor='hand2')

            inner = tk.Frame(card, bg=self.BG_PANEL, padx=20, pady=15)
            inner.pack(fill=tk.BOTH, expand=True)
            inner.bind('<Button-1>', lambda e, x=i: self.manage_profile(x))

            slot_label = tk.Label(inner, text=f"SLOT {i+1}", font=('Arial', 9),
                                 fg=self.DARK_GRAY, bg=self.BG_PANEL)
            slot_label.pack()
            slot_label.bind('<Button-1>', lambda e, x=i: self.manage_profile(x))

            name_label = tk.Label(inner, text="Empty", font=('Arial Bold', 14),
                                 fg=self.WHITE, bg=self.BG_PANEL, width=12)
            name_label.pack(pady=(5, 2))
            name_label.bind('<Button-1>', lambda e, x=i: self.manage_profile(x))

            status_label = tk.Label(inner, text="Click to create", font=('Arial', 9),
                                   fg=self.GRAY, bg=self.BG_PANEL)
            status_label.pack()
            status_label.bind('<Button-1>', lambda e, x=i: self.manage_profile(x))

            self.profile_frames.append(card)
            self.profile_name_labels.append(name_label)
            self.profile_status_labels.append(status_label)

        self.update_profiles()

    def update_profiles(self):
        """Refresh profile display"""
        self.profile_dir.mkdir(parents=True, exist_ok=True)

        for i in range(4):
            profile_path = self.profile_dir / f"profile{i}.dat"
            card = self.profile_frames[i]
            name_label = self.profile_name_labels[i]
            status_label = self.profile_status_labels[i]

            if profile_path.exists():
                name = self.get_profile_name(i)
                name_label.configure(text=name, fg=self.CYAN)
                status_label.configure(text="Click to manage", fg='#4a8866')
                card.configure(bg='#1a2e1a')
                for child in card.winfo_children():
                    child.configure(bg='#1a2e1a')
                    for subchild in child.winfo_children():
                        subchild.configure(bg='#1a2e1a')
            else:
                name_label.configure(text="Empty", fg=self.GRAY)
                status_label.configure(text="Click to create", fg=self.DARK_GRAY)
                card.configure(bg=self.BG_PANEL)
                for child in card.winfo_children():
                    child.configure(bg=self.BG_PANEL)
                    for subchild in child.winfo_children():
                        subchild.configure(bg=self.BG_PANEL)

    def launch_game(self):
        # Check if at least one profile exists
        profiles_exist = any((self.profile_dir / f"profile{i}.dat").exists() for i in range(4))
        if not profiles_exist:
            messagebox.showwarning("No Profile",
                "You must create at least one profile before playing!\n\n"
                "Click on an empty slot to create a profile.")
            self.status_var.set("Create a profile first!")
            return

        self.status_var.set("Launching...")
        self.root.update()
        launcher = self.game_dir / "Penguins.sh"
        if launcher.exists():
            subprocess.Popen([str(launcher)], cwd=str(self.game_dir))
            self.root.quit()
        else:
            messagebox.showerror("Error", "Launcher not found!")
            self.status_var.set("Error")

    def manage_profile(self, num):
        profile_path = self.profile_dir / f"profile{num}.dat"
        pending_path = self.game_dir / f".pending_username_{num}"

        if profile_path.exists():
            name = self.get_profile_name(num)

            popup = tk.Toplevel(self.root)
            popup.title(f"Profile {num + 1}")
            popup.geometry("320x220")
            popup.configure(bg=self.BG_PANEL)
            popup.transient(self.root)
            popup.grab_set()
            popup.resizable(False, False)

            # Center
            popup.update_idletasks()
            x = self.root.winfo_x() + (800 - 320) // 2
            y = self.root.winfo_y() + (480 - 220) // 2
            popup.geometry(f"320x220+{x}+{y}")

            tk.Label(popup, text=name, font=('Arial Bold', 16),
                    fg=self.CYAN, bg=self.BG_PANEL).pack(pady=(15, 10))

            # Edit options
            btn_frame = tk.Frame(popup, bg=self.BG_PANEL)
            btn_frame.pack(pady=5)

            def rename():
                popup.destroy()
                new_name = simpledialog.askstring("Rename", "New username:", initialvalue=name)
                if new_name and new_name != name:
                    if self.rename_profile(num, new_name):
                        self.status_var.set(f"Renamed to '{new_name}'")
                    else:
                        messagebox.showerror("Error", "Rename failed")
                    self.update_profiles()

            def copy_to():
                popup.destroy()
                # Find empty slots
                empty = [i for i in range(4) if i != num and not (self.profile_dir / f"profile{i}.dat").exists()]
                if not empty:
                    messagebox.showinfo("Copy", "No empty slots available")
                    return
                slot = simpledialog.askinteger("Copy", f"Copy to slot (available: {[s+1 for s in empty]}):",
                                               minvalue=1, maxvalue=4)
                if slot and (slot-1) in empty:
                    shutil.copy(profile_path, self.profile_dir / f"profile{slot-1}.dat")
                    self.status_var.set(f"Copied to Slot {slot}")
                    self.update_profiles()

            def reset():
                popup.destroy()
                if messagebox.askyesno("Reset", f"Reset '{name}' to fresh start?\nAll progress will be lost!"):
                    # Keep name, reset everything else
                    success, msg = self.create_profile(num, name)
                    if success:
                        self.status_var.set(f"'{name}' reset to fresh")
                    self.update_profiles()

            def delete():
                popup.destroy()
                if messagebox.askyesno("Delete", f"Delete '{name}'?"):
                    profile_path.unlink()
                    self.status_var.set("Deleted")
                    self.update_profiles()

            tk.Button(btn_frame, text="Rename", font=('Arial', 10),
                     bg=self.BG_BUTTON, fg=self.WHITE, relief=tk.FLAT,
                     width=12, command=rename).pack(pady=3)

            tk.Button(btn_frame, text="Copy to Slot", font=('Arial', 10),
                     bg=self.BG_BUTTON, fg=self.WHITE, relief=tk.FLAT,
                     width=12, command=copy_to).pack(pady=3)

            tk.Button(btn_frame, text="Reset Progress", font=('Arial', 10),
                     bg='#6b5a1a', fg=self.WHITE, relief=tk.FLAT,
                     width=12, command=reset).pack(pady=3)

            tk.Button(btn_frame, text="Delete", font=('Arial', 10),
                     bg=self.BG_RED, fg=self.WHITE, relief=tk.FLAT,
                     width=12, command=delete).pack(pady=3)

            tk.Button(popup, text="Cancel", font=('Arial', 10),
                     bg=self.BG_BUTTON, fg=self.WHITE, relief=tk.FLAT,
                     width=10, command=popup.destroy).pack(pady=10)

        else:
            # Empty slot - create new profile
            username = simpledialog.askstring("New Profile",
                f"Enter username for Slot {num + 1}:", initialvalue=f"Player{num + 1}")
            if username:
                success, msg = self.create_profile(num, username)
                if success:
                    self.status_var.set(msg)
                    messagebox.showinfo("Created", f"Profile '{username}' created!")
                else:
                    self.status_var.set("Failed")
                    messagebox.showerror("Error", f"Failed to create profile:\n{msg}")
                self.update_profiles()

    def check_updates(self):
        self.status_var.set("Checking...")
        self.root.update()

        if not (self.game_dir / ".git").exists():
            messagebox.showinfo("Updates", "No git repo.\nReinstall from GitHub for updates.")
            self.status_var.set("Ready")
            return

        try:
            subprocess.run(["git", "fetch", "origin"], cwd=str(self.game_dir),
                          capture_output=True, timeout=30)
            local = subprocess.run(["git", "rev-parse", "HEAD"],
                                  cwd=str(self.game_dir), capture_output=True, text=True)
            remote = subprocess.run(["git", "rev-parse", "origin/main"],
                                   cwd=str(self.game_dir), capture_output=True, text=True)

            if local.stdout.strip() != remote.stdout.strip():
                if messagebox.askyesno("Update", "Update available!\nDownload?"):
                    subprocess.run(["git", "pull", "origin", "main"], cwd=str(self.game_dir))
                    messagebox.showinfo("Done", "Updated!\nRestart manager.")
                    self.status_var.set("Restart manager")
            else:
                messagebox.showinfo("Updates", "You're up to date!")
                self.status_var.set("Up to date")
        except Exception as e:
            messagebox.showerror("Error", str(e))
            self.status_var.set("Error")

    def repair_install(self):
        if not messagebox.askyesno("Repair", "Reset game files?\nProfiles preserved."):
            return

        self.status_var.set("Repairing...")
        self.root.update()

        prefix = self.game_dir / "prefix"
        template = self.game_dir / "prefix_template"
        backup = self.game_dir / "profile_backup"

        try:
            if self.profile_dir.exists():
                backup.mkdir(exist_ok=True)
                for f in self.profile_dir.glob("*.dat"):
                    shutil.copy(f, backup)

            if prefix.exists():
                shutil.rmtree(prefix)
            if template.exists():
                shutil.copytree(template, prefix)

            if backup.exists():
                self.profile_dir.mkdir(parents=True, exist_ok=True)
                for f in backup.glob("*.dat"):
                    shutil.copy(f, self.profile_dir)
                shutil.rmtree(backup)

            self.update_profiles()
            messagebox.showinfo("Done", "Repair complete!")
            self.status_var.set("Repaired")
        except Exception as e:
            messagebox.showerror("Error", str(e))
            self.status_var.set("Error")

    def run(self):
        self.root.mainloop()


if __name__ == "__main__":
    app = PenguinsManager()
    app.run()
