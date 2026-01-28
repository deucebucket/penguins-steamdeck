#!/usr/bin/env python3
"""
Penguins! Game Manager
Single-window GUI for managing the game
"""

import tkinter as tk
from tkinter import ttk, messagebox, simpledialog
import subprocess
import os
import shutil
from pathlib import Path

class PenguinsManager:
    def __init__(self):
        self.game_dir = Path(__file__).parent.resolve()
        self.profile_dir = self.game_dir / "prefix/pfx/drive_c/ProgramData/WildTangent/penguins/Persistent/resources/profiles"

        # Create main window
        self.root = tk.Tk()
        self.root.title("Penguins! Game Manager")
        self.root.geometry("400x500")
        self.root.resizable(False, False)

        # Style
        self.root.configure(bg='#2b2b3d')
        style = ttk.Style()
        style.theme_use('clam')
        style.configure('TButton', padding=10, font=('Helvetica', 11))
        style.configure('TLabel', background='#2b2b3d', foreground='white', font=('Helvetica', 11))
        style.configure('Header.TLabel', font=('Helvetica', 18, 'bold'))
        style.configure('TFrame', background='#2b2b3d')

        self.create_widgets()

    def create_widgets(self):
        # Main frame
        main_frame = ttk.Frame(self.root, padding=20)
        main_frame.pack(fill=tk.BOTH, expand=True)

        # Header
        header = ttk.Label(main_frame, text="🐧 Penguins!", style='Header.TLabel')
        header.pack(pady=(0, 5))

        subtitle = ttk.Label(main_frame, text="Game Manager v2.5")
        subtitle.pack(pady=(0, 5))

        credit = ttk.Label(main_frame, text="by deucebucket", font=('Helvetica', 9))
        credit.pack(pady=(0, 15))

        # Launch button (prominent)
        launch_btn = tk.Button(main_frame, text="🎮  Launch Game",
                              command=self.launch_game,
                              bg='#4CAF50', fg='white',
                              font=('Helvetica', 14, 'bold'),
                              height=2, width=20)
        launch_btn.pack(pady=10)

        # Separator
        ttk.Separator(main_frame, orient='horizontal').pack(fill=tk.X, pady=15)

        # Profile section
        profile_label = ttk.Label(main_frame, text="👤 User Profiles")
        profile_label.pack(pady=(0, 10))

        # Profile buttons frame
        profile_frame = ttk.Frame(main_frame)
        profile_frame.pack(fill=tk.X, pady=5)

        self.profile_buttons = []
        for i in range(4):
            btn = tk.Button(profile_frame, text=f"Profile {i+1}",
                           command=lambda x=i: self.manage_profile(x),
                           bg='#3d3d5c', fg='white',
                           width=8, height=1)
            btn.pack(side=tk.LEFT, padx=5, expand=True)
            self.profile_buttons.append(btn)

        self.update_profile_buttons()

        # Separator
        ttk.Separator(main_frame, orient='horizontal').pack(fill=tk.X, pady=15)

        # Other actions
        actions_frame = ttk.Frame(main_frame)
        actions_frame.pack(fill=tk.X, pady=5)

        update_btn = tk.Button(actions_frame, text="⬇️ Check Updates",
                              command=self.check_updates,
                              bg='#3d3d5c', fg='white', width=15)
        update_btn.pack(side=tk.LEFT, padx=5, expand=True)

        repair_btn = tk.Button(actions_frame, text="🔧 Repair Install",
                              command=self.repair_install,
                              bg='#3d3d5c', fg='white', width=15)
        repair_btn.pack(side=tk.LEFT, padx=5, expand=True)

        # Status bar
        self.status_var = tk.StringVar(value="Ready")
        status_bar = ttk.Label(main_frame, textvariable=self.status_var)
        status_bar.pack(side=tk.BOTTOM, pady=(20, 0))

        # Exit button
        exit_btn = tk.Button(main_frame, text="Exit", command=self.root.quit,
                            bg='#5c3d3d', fg='white', width=10)
        exit_btn.pack(side=tk.BOTTOM, pady=(10, 0))

    def update_profile_buttons(self):
        """Update profile button colors based on existence"""
        self.profile_dir.mkdir(parents=True, exist_ok=True)
        for i, btn in enumerate(self.profile_buttons):
            profile_path = self.profile_dir / f"profile{i}.dat"
            if profile_path.exists():
                btn.configure(bg='#4a7c4a', text=f"Profile {i+1} ✓")
            else:
                btn.configure(bg='#3d3d5c', text=f"Profile {i+1}")

    def launch_game(self):
        """Launch the game"""
        self.status_var.set("Launching game...")
        self.root.update()

        launcher = self.game_dir / "Penguins.sh"
        if launcher.exists():
            subprocess.Popen([str(launcher)], cwd=str(self.game_dir))
            self.root.quit()
        else:
            messagebox.showerror("Error", "Launcher not found!")
            self.status_var.set("Error: Launcher not found")

    def manage_profile(self, profile_num):
        """Manage a specific profile"""
        profile_path = self.profile_dir / f"profile{profile_num}.dat"

        if profile_path.exists():
            # Profile exists - ask what to do
            result = messagebox.askyesnocancel(
                f"Profile {profile_num + 1}",
                f"Profile {profile_num + 1} exists.\n\nYes = Delete profile\nNo = Keep profile\nCancel = Cancel"
            )
            if result is True:  # Yes = Delete
                profile_path.unlink()
                self.status_var.set(f"Profile {profile_num + 1} deleted")
                self.update_profile_buttons()
            elif result is False:  # No = Keep
                self.status_var.set(f"Profile {profile_num + 1} kept")
        else:
            # New profile - ask for username
            username = simpledialog.askstring(
                "New Profile",
                f"Enter username for Profile {profile_num + 1}:",
                initialvalue=f"Player{profile_num + 1}"
            )
            if username:
                # Save pending username for game to pick up
                pending_file = self.game_dir / f".pending_username_{profile_num}"
                pending_file.write_text(username)
                self.status_var.set(f"Username '{username}' set - launch game to create profile")
                messagebox.showinfo("Profile Setup",
                    f"Username '{username}' saved.\n\nLaunch the game and create a new profile to activate it.")

    def check_updates(self):
        """Check for updates via git"""
        self.status_var.set("Checking for updates...")
        self.root.update()

        git_dir = self.game_dir / ".git"
        if not git_dir.exists():
            messagebox.showinfo("Updates", "Update check requires git repository.\nReinstall from GitHub to enable updates.")
            self.status_var.set("Ready")
            return

        try:
            # Fetch
            subprocess.run(["git", "fetch", "origin"], cwd=str(self.game_dir),
                          capture_output=True, timeout=30)

            # Check if behind
            local = subprocess.run(["git", "rev-parse", "HEAD"],
                                  cwd=str(self.game_dir), capture_output=True, text=True)
            remote = subprocess.run(["git", "rev-parse", "origin/main"],
                                   cwd=str(self.game_dir), capture_output=True, text=True)

            if local.stdout.strip() != remote.stdout.strip():
                if messagebox.askyesno("Update Available", "An update is available!\n\nDownload and install?"):
                    subprocess.run(["git", "pull", "origin", "main"], cwd=str(self.game_dir))
                    messagebox.showinfo("Updated", "Update complete!\nPlease restart the manager.")
                    self.status_var.set("Update complete - restart manager")
                else:
                    self.status_var.set("Update skipped")
            else:
                messagebox.showinfo("Updates", "You have the latest version!")
                self.status_var.set("Already up to date")
        except Exception as e:
            messagebox.showerror("Error", f"Update check failed:\n{e}")
            self.status_var.set("Update check failed")

    def repair_install(self):
        """Repair the installation"""
        if not messagebox.askyesno("Repair Install",
            "This will reset the game prefix.\nYour profiles will be preserved.\n\nContinue?"):
            return

        self.status_var.set("Repairing installation...")
        self.root.update()

        prefix = self.game_dir / "prefix"
        template = self.game_dir / "prefix_template"
        backup = self.game_dir / "profile_backup"

        try:
            # Backup profiles
            if self.profile_dir.exists():
                backup.mkdir(exist_ok=True)
                for f in self.profile_dir.glob("*.dat"):
                    shutil.copy(f, backup)

            # Reset prefix
            if prefix.exists():
                shutil.rmtree(prefix)
            if template.exists():
                shutil.copytree(template, prefix)

            # Restore profiles
            if backup.exists():
                self.profile_dir.mkdir(parents=True, exist_ok=True)
                for f in backup.glob("*.dat"):
                    shutil.copy(f, self.profile_dir)
                shutil.rmtree(backup)

            self.update_profile_buttons()
            messagebox.showinfo("Repair Complete", "Installation repaired successfully!")
            self.status_var.set("Repair complete")
        except Exception as e:
            messagebox.showerror("Error", f"Repair failed:\n{e}")
            self.status_var.set("Repair failed")

    def run(self):
        self.root.mainloop()


if __name__ == "__main__":
    app = PenguinsManager()
    app.run()
