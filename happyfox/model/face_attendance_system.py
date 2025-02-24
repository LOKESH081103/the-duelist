import cv2
import numpy as np
import sqlite3
from datetime import datetime
import os
from typing import Dict, List
import gradio as gr
from PIL import Image
import io
import base64

class DatabaseHandler:
    def __init__(self):
        self.conn = sqlite3.connect('attendance.db', check_same_thread=False)
        self.cursor = self.conn.cursor()
        self.create_tables()

    def create_tables(self):
        self.cursor.execute("""
            CREATE TABLE IF NOT EXISTS students (
                student_id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT,
                email TEXT,
                face_image BLOB,
                registration_date DATETIME DEFAULT (datetime('now', 'localtime'))
            )
        """)

        self.cursor.execute("""
            CREATE TABLE IF NOT EXISTS attendance (
                attendance_id INTEGER PRIMARY KEY AUTOINCREMENT,
                student_id INTEGER,
                check_in DATETIME,
                check_out DATETIME,
                attendance_date DATE DEFAULT (date('now', 'localtime')),
                FOREIGN KEY (student_id) REFERENCES students(student_id)
            )
        """)
        
        self.conn.commit()

class SimpleFaceRecognitionSystem:
    def __init__(self):
        self.db = DatabaseHandler()
        self.face_cascade = cv2.CascadeClassifier(
            cv2.data.haarcascades + 'haarcascade_frontalface_default.xml'
        )
        self.face_recognizer = cv2.face_LBPHFaceRecognizer.create()
        self.known_faces = {}
        self.load_registered_faces()

    def load_registered_faces(self):
        self.db.cursor.execute("SELECT student_id, face_image FROM students")
        registered_faces = self.db.cursor.fetchall()
        
        if not registered_faces:
            return

        face_images = []
        labels = []
        
        for student_id, face_image in registered_faces:
            if face_image is not None:
                # Convert BYTEA to numpy array
                nparr = np.frombuffer(face_image, np.uint8)
                img = cv2.imdecode(nparr, cv2.IMREAD_GRAYSCALE)
                
                faces = self.face_cascade.detectMultiScale(img)
                if len(faces) > 0:
                    (x, y, w, h) = faces[0]
                    face_roi = img[y:y+h, x:x+w]
                    face_images.append(face_roi)
                    labels.append(student_id)
                    self.known_faces[student_id] = True

        if face_images:
            self.face_recognizer.train(face_images, np.array(labels))

    def register_student(self, name: str, email: str, image_path: str) -> int:
        # Read and process the image
        img = cv2.imread(image_path)
        gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
        
        faces = self.face_cascade.detectMultiScale(gray)
        if not len(faces):
            raise ValueError("No face detected in the image")
            
        # Get the first detected face
        (x, y, w, h) = faces[0]
        face_roi = gray[y:y+h, x:x+w]
        
        # Convert image to BYTEA for storage
        _, img_encoded = cv2.imencode('.jpg', img)
        face_bytes = img_encoded.tobytes()
        
        # Store in database
        self.db.cursor.execute("""
            INSERT INTO students (name, email, face_image)
            VALUES (?, ?, ?)
        """, (name, email, face_bytes))
        
        # Get the last inserted id
        student_id = self.db.cursor.lastrowid
        self.db.conn.commit()
        
        # Update face recognizer
        if len(self.known_faces) > 0:
            self.face_recognizer.update([face_roi], np.array([student_id]))
        else:
            self.face_recognizer.train([face_roi], np.array([student_id]))
        
        self.known_faces[student_id] = True
        return student_id

    def process_image_for_attendance(self, image, is_webcam=False):
        """Process either webcam frame or uploaded image for attendance"""
        if image is None:
            return None
        
        # Convert PIL Image to cv2 format if it's not from webcam
        if not is_webcam:
            image = cv2.cvtColor(np.array(image), cv2.COLOR_RGB2BGR)
        
        # Convert to grayscale
        gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
        faces = self.face_cascade.detectMultiScale(gray)
        
        attendance_marked = False
        for (x, y, w, h) in faces:
            face_roi = gray[y:y+h, x:x+w]
            
            if len(self.known_faces) > 0:
                label, confidence = self.face_recognizer.predict(face_roi)
                
                if confidence < 100:  # Adjust threshold as needed
                    student_id = label
                    self.mark_attendance(student_id)
                    attendance_marked = True
                    
                    # Get student name
                    self.db.cursor.execute(
                        "SELECT name FROM students WHERE student_id = ?",
                        (student_id,)
                    )
                    student_name = self.db.cursor.fetchone()[0]
                    
                    # Draw rectangle and name
                    cv2.rectangle(image, (x, y), (x+w, y+h), (0, 255, 0), 2)
                    cv2.putText(image, f"{student_name}", (x, y-10),
                              cv2.FONT_HERSHEY_SIMPLEX, 0.9, (0, 255, 0), 2)
        
        return image, "Attendance marked successfully!" if attendance_marked else "No registered face detected"

    def process_webcam_frame(self, frame):
        """Process webcam frame"""
        marked_frame, _ = self.process_image_for_attendance(frame, is_webcam=True)
        return marked_frame

    def mark_attendance(self, student_id):
        # Check if student already has attendance for today
        self.db.cursor.execute("""
            SELECT attendance_id, check_in, check_out 
            FROM attendance 
            WHERE student_id = ? AND date(attendance_date) = date('now', 'localtime')
        """, (student_id,))
        
        attendance_record = self.db.cursor.fetchone()
        current_time = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        
        if attendance_record is None:
            # Mark check-in
            self.db.cursor.execute("""
                INSERT INTO attendance (student_id, check_in)
                VALUES (?, ?)
            """, (student_id, current_time))
        elif attendance_record[2] is None:
            # Mark check-out
            self.db.cursor.execute("""
                UPDATE attendance 
                SET check_out = ?
                WHERE attendance_id = ?
            """, (current_time, attendance_record[0]))
        
        self.db.conn.commit()

    def register_student_gradio(self, name, email, image):
        """Gradio-compatible method for student registration"""
        try:
            # Save the uploaded image temporarily
            temp_path = "temp_upload.jpg"
            image.save(temp_path)
            
            # Register the student
            student_id = self.register_student(name, email, temp_path)
            
            # Clean up
            os.remove(temp_path)
            
            return f"Student registered successfully! ID: {student_id}"
        except Exception as e:
            return f"Registration failed: {str(e)}"

    def get_attendance_report(self, date=None):
        """Generate enhanced attendance report with additional statistics"""
        if date:
            date_condition = "date(attendance_date) = date(?)"
            params = (date,)
        else:
            date_condition = "date(attendance_date) = date('now', 'localtime')"
            params = ()
        
        # Get detailed attendance records
        self.db.cursor.execute(f"""
            SELECT 
                s.name,
                a.check_in,
                a.check_out,
                CASE 
                    WHEN a.check_out IS NOT NULL 
                    THEN time(
                        (julianday(a.check_out) - julianday(a.check_in)) * 24, 
                        'hours'
                    )
                    ELSE NULL 
                END as duration,
                CASE 
                    WHEN time(a.check_in) <= time('09:00:00') THEN 'On Time'
                    WHEN time(a.check_in) <= time('09:30:00') THEN 'Late'
                    ELSE 'Very Late'
                END as status
            FROM attendance a
            JOIN students s ON a.student_id = s.student_id
            WHERE {date_condition}
            ORDER BY a.check_in
        """, params)
        
        records = self.db.cursor.fetchall()
        
        if not records:
            return "No attendance records found for this date."
        
        # Calculate statistics
        total_students = len(records)
        on_time = sum(1 for r in records if r[4] == 'On Time')
        late = sum(1 for r in records if r[4] == 'Late')
        very_late = sum(1 for r in records if r[4] == 'Very Late')
        still_present = sum(1 for r in records if r[2] is None)
        
        # Format the detailed report
        report = "📊 Attendance Report Summary 📊\n"
        report += f"Date: {date or datetime.now().strftime('%Y-%m-%d')}\n"
        report += "-" * 50 + "\n\n"
        
        # Add statistics section
        report += "📈 Statistics:\n"
        report += f"Total Students: {total_students}\n"
        report += f"On Time: {on_time} ({(on_time/total_students)*100:.1f}%)\n"
        report += f"Late: {late} ({(late/total_students)*100:.1f}%)\n"
        report += f"Very Late: {very_late} ({(very_late/total_students)*100:.1f}%)\n"
        report += f"Currently Present: {still_present}\n"
        report += "-" * 50 + "\n\n"
        
        # Add detailed attendance records
        report += "👥 Detailed Attendance Records:\n"
        report += "Name | Check-in | Check-out | Duration | Status\n"
        report += "-" * 70 + "\n"
        
        for record in records:
            name, check_in, check_out, duration, status = record
            duration_str = duration or "Still Present"
            check_out_str = check_out or "Not checked out"
            status_emoji = {
                'On Time': '✅',
                'Late': '⚠️',
                'Very Late': '❌'
            }.get(status, '')
            
            report += (f"{name} | {check_in} | {check_out_str} | "
                      f"{duration_str} | {status_emoji} {status}\n")
        
        # Add weekly/monthly statistics if available
        report += "\n📅 Weekly Statistics:\n"
        self.db.cursor.execute("""
            SELECT 
                COUNT(*) as total_attendance,
                SUM(CASE WHEN time(check_in) <= time('09:00:00') THEN 1 ELSE 0 END) as on_time
            FROM attendance
            WHERE date(attendance_date) >= date('now', '-7 days')
        """)
        weekly_stats = self.db.cursor.fetchone()
        report += f"Past 7 days: {weekly_stats[1]} on-time out of {weekly_stats[0]} total attendances\n"
        
        return report

def create_gradio_interface():
    face_system = SimpleFaceRecognitionSystem()
    
    with gr.Blocks(title="Face Recognition Attendance System") as interface:
        gr.Markdown("# Face Recognition Attendance System")
        
        with gr.Tab("Register Student"):
            with gr.Row():
                with gr.Column():
                    name_input = gr.Textbox(label="Student Name")
                    email_input = gr.Textbox(label="Student Email")
                    image_input = gr.Image(label="Student Photo", type="pil")
                    register_button = gr.Button("Register Student")
                with gr.Column():
                    register_output = gr.Textbox(label="Registration Status")
            
            register_button.click(
                fn=face_system.register_student_gradio,
                inputs=[name_input, email_input, image_input],
                outputs=register_output
            )
        
        with gr.Tab("Mark Attendance"):
            gr.Markdown("### Choose either webcam or upload a photo")
            
            with gr.Row():
                with gr.Column():
                    gr.Markdown("#### Using Webcam")
                    webcam_input = gr.Image(sources=["webcam"], streaming=True)
                    attendance_output_webcam = gr.Image(label="Attendance Status")
                
                with gr.Column():
                    gr.Markdown("#### Using Photo")
                    photo_input = gr.Image(label="Upload Photo", type="pil")
                    mark_button = gr.Button("Mark Attendance")
                    with gr.Row():
                        attendance_output_photo = gr.Image(label="Processed Photo")
                        attendance_status = gr.Textbox(label="Status")
            
            # Webcam stream
            webcam_input.stream(
                fn=face_system.process_webcam_frame,
                inputs=webcam_input,
                outputs=attendance_output_webcam
            )
            
            # Photo upload
            mark_button.click(
                fn=lambda img: face_system.process_image_for_attendance(img, is_webcam=False),
                inputs=photo_input,
                outputs=[attendance_output_photo, attendance_status]
            )
        
        with gr.Tab("View Attendance Report"):
            with gr.Row():
                date_input = gr.Textbox(
                    label="Date (YYYY-MM-DD)", 
                    placeholder="Leave empty for today's report"
                )
                report_type = gr.Radio(
                    choices=["Daily", "Weekly", "Monthly"],
                    label="Report Type",
                    value="Daily"
                )
                report_button = gr.Button("Generate Report")
            
            report_output = gr.Textbox(
                label="Attendance Report",
                lines=20,
                max_lines=30
            )
            
            # Add download button for report
            download_btn = gr.Button("📥 Download Report")
            
            def download_report(date, report_type):
                report = face_system.get_attendance_report(date)
                filename = f"attendance_report_{date or 'today'}.txt"
                with open(filename, 'w') as f:
                    f.write(report)
                return filename
            
            download_btn.click(
                fn=download_report,
                inputs=[date_input, report_type],
                outputs=gr.File()
            )
            
            report_button.click(
                fn=face_system.get_attendance_report,
                inputs=[date_input],
                outputs=report_output
            )
    
    return interface

def main():
    interface = create_gradio_interface()
    interface.launch(share=True)

if __name__ == "__main__":
    main() 