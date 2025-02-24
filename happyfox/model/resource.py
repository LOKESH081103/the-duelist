import torch
from transformers import BertTokenizer, BertModel
from sklearn.metrics.pairwise import cosine_similarity
import numpy as np
import psycopg2
from datetime import datetime
from typing import Dict, List

class DatabaseHandler:
    def _init_(self):
        self.conn = psycopg2.connect(
            dbname="resource_sharing",
            user="your_username",
            password="your_password",
            host="localhost",
            port="5432"
        )
        self.cursor = self.conn.cursor()
        self.create_tables()

    def create_tables(self):
        # Create tables if they don't exist
        self.cursor.execute("""
            CREATE TABLE IF NOT EXISTS students (
                student_id SERIAL PRIMARY KEY,
                name VARCHAR(100),
                email VARCHAR(100),
                experience_points INTEGER DEFAULT 0
            )
        """)

        self.cursor.execute("""
            CREATE TABLE IF NOT EXISTS resources (
                resource_id SERIAL PRIMARY KEY,
                type VARCHAR(50),
                name VARCHAR(100),
                description TEXT,
                owner_id INTEGER REFERENCES students(student_id),
                status VARCHAR(20),
                cost FLOAT,
                embedding BYTEA,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                is_available BOOLEAN DEFAULT TRUE
            )
        """)

        self.cursor.execute("""
            CREATE TABLE IF NOT EXISTS transactions (
                transaction_id SERIAL PRIMARY KEY,
                resource_id INTEGER REFERENCES resources(resource_id),
                provider_id INTEGER REFERENCES students(student_id),
                receiver_id INTEGER REFERENCES students(student_id),
                transaction_type VARCHAR(20),
                points_earned INTEGER,
                transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        """)

        self.cursor.execute("""
            CREATE TABLE IF NOT EXISTS rewards (
                reward_id SERIAL PRIMARY KEY,
                name VARCHAR(100),
                description TEXT,
                points_required INTEGER,
                is_available BOOLEAN DEFAULT TRUE
            )
        """)
        
        # Insert some default rewards
        self.cursor.execute("""
            INSERT INTO rewards (name, description, points_required)
            VALUES 
                ('Library Extension', 'Extended library access for 1 month', 100),
                ('Stationary Discount', '20% off on stationary items', 50),
                ('Printing Credits', '100 pages free printing', 75)
            ON CONFLICT DO NOTHING
        """)
        
        self.conn.commit()

class ResourceMatcher:
    def _init_(self):
        self.tokenizer = BertTokenizer.from_pretrained('bert-base-uncased')
        self.model = BertModel.from_pretrained('bert-base-uncased')
        self.model.eval()
        self.db = DatabaseHandler()

    def get_bert_embedding(self, text):
        inputs = self.tokenizer(text, return_tensors="pt", padding=True, truncation=True, max_length=128)
        with torch.no_grad():
            outputs = self.model(**inputs)
            embeddings = outputs.last_hidden_state.mean(dim=1)
        return embeddings.numpy().tobytes()  # Convert to bytes for storage

    def calculate_points(self, transaction_type: str, resource_type: str) -> int:
        # Points system
        points_map = {
            'lending': {
                'book': 20,
                'notes': 15,
                'hardware': 25
            },
            'giveaway': {
                'book': 30,
                'notes': 25,
                'hardware': 35
            }
        }
        return points_map.get(transaction_type, {}).get(resource_type, 10)

    def add_resource(self, student_id: int, resource_info: Dict):
        description = f"{resource_info['type']} {resource_info['name']} {resource_info['description']}"
        embedding = self.get_bert_embedding(description)
        
        self.db.cursor.execute("""
            INSERT INTO resources (type, name, description, owner_id, status, cost, embedding)
            VALUES (%s, %s, %s, %s, %s, %s, %s)
            RETURNING resource_id
        """, (
            resource_info['type'],
            resource_info['name'],
            resource_info['description'],
            student_id,
            resource_info['status'],
            resource_info.get('cost', 0),
            embedding
        ))
        self.db.conn.commit()
        return "Resource added successfully!"

    def find_matches(self, query: str, threshold: float = 0.7) -> List[Dict]:
        query_embedding = self.get_bert_embedding(query)
        
        self.db.cursor.execute("""
            SELECT r.*, s.name as owner_name, s.email
            FROM resources r
            JOIN students s ON r.owner_id = s.student_id
            WHERE r.is_available = TRUE
        """)
        
        resources = self.db.cursor.fetchall()
        matches = []
        
        for resource in resources:
            stored_embedding = np.frombuffer(resource[7])  # embedding column
            similarity = cosine_similarity(
                query_embedding.reshape(1, -1),
                stored_embedding.reshape(1, -1)
            )[0][0]
            
            if similarity > threshold:
                matches.append({
                    'resource': {
                        'id': resource[0],
                        'type': resource[1],
                        'name': resource[2],
                        'description': resource[3],
                        'status': resource[5],
                        'cost': resource[6],
                        'owner_name': resource[9],
                        'owner_email': resource[10]
                    },
                    'similarity': similarity
                })
        
        matches.sort(key=lambda x: x['similarity'], reverse=True)
        return matches

    def process_transaction(self, resource_id: int, provider_id: int, receiver_id: int):
        # Get resource details
        self.db.cursor.execute("""
            SELECT type, status FROM resources WHERE resource_id = %s
        """, (resource_id,))
        resource_type, transaction_type = self.db.cursor.fetchone()
        
        # Calculate points
        points = self.calculate_points(transaction_type, resource_type)
        
        # Record transaction
        self.db.cursor.execute("""
            INSERT INTO transactions 
            (resource_id, provider_id, receiver_id, transaction_type, points_earned)
            VALUES (%s, %s, %s, %s, %s)
        """, (resource_id, provider_id, receiver_id, transaction_type, points))
        
        # Update provider's points
        self.db.cursor.execute("""
            UPDATE students 
            SET experience_points = experience_points + %s
            WHERE student_id = %s
        """, (points, provider_id))
        
        # Mark resource as unavailable
        self.db.cursor.execute("""
            UPDATE resources
            SET is_available = FALSE
            WHERE resource_id = %s
        """, (resource_id,))
        
        self.db.conn.commit()
        return points

def main():
    matcher = ResourceMatcher()
    
    while True:
        print("\n=== Resource Sharing Platform ===")
        print("1. Register Student")
        print("2. Add Resource")
        print("3. Search Resource")
        print("4. View Available Rewards")
        print("5. Redeem Reward")
        print("6. Exit")
        
        choice = input("Enter your choice (1-6): ")
        
        if choice == '1':
            name = input("Enter your name: ")
            email = input("Enter your email: ")
            
            matcher.db.cursor.execute("""
                INSERT INTO students (name, email)
                VALUES (%s, %s)
                RETURNING student_id
            """, (name, email))
            student_id = matcher.db.cursor.fetchone()[0]
            matcher.db.conn.commit()
            print(f"Registered successfully! Your ID is: {student_id}")
            
        elif choice == '2':
            student_id = int(input("Enter your student ID: "))
            resource = {
                'type': input("Enter resource type (book/notes/hardware): "),
                'name': input("Enter resource name: "),
                'description': input("Enter description: "),
                'status': input("Enter status (lending/giveaway): "),
                'cost': float(input("Enter cost (0 for free): "))
            }
            print(matcher.add_resource(student_id, resource))
            
        elif choice == '3':
            query = input("What resource are you looking for? ")
            matches = matcher.find_matches(query)
            
            if matches:
                print("\nFound matching resources:")
                for idx, match in enumerate(matches, 1):
                    resource = match['resource']
                    print(f"\n{idx}. Similarity: {match['similarity']:.2f}")
                    print(f"Type: {resource['type']}")
                    print(f"Name: {resource['name']}")
                    print(f"Description: {resource['description']}")
                    print(f"Owner: {resource['owner_name']}")
                    print(f"Status: {resource['status']}")
                    print(f"Cost: ${resource['cost']}")
                    print(f"Contact: {resource['owner_email']}")
                    
                # Option to request resource
                choice = input("\nEnter resource number to request (or 0 to skip): ")
                if choice.isdigit() and int(choice) > 0 and int(choice) <= len(matches):
                    resource = matches[int(choice)-1]['resource']
                    receiver_id = int(input("Enter your student ID: "))
                    points = matcher.process_transaction(
                        resource['id'],
                        resource['owner_id'],
                        receiver_id
                    )
                    print(f"Transaction successful! Provider earned {points} points!")
            else:
                print("No matching resources found.")
                
        elif choice == '4':
            matcher.db.cursor.execute("SELECT * FROM rewards WHERE is_available = TRUE")
            rewards = matcher.db.cursor.fetchall()
            print("\nAvailable Rewards:")
            for reward in rewards:
                print(f"\nID: {reward[0]}")
                print(f"Name: {reward[1]}")
                print(f"Description: {reward[2]}")
                print(f"Points Required: {reward[3]}")
                
        elif choice == '5':
            student_id = int(input("Enter your student ID: "))
            reward_id = int(input("Enter reward ID: "))
            
            # Check points and redeem
            matcher.db.cursor.execute("""
                SELECT s.experience_points, r.points_required, r.name
                FROM students s, rewards r
                WHERE s.student_id = %s AND r.reward_id = %s
            """, (student_id, reward_id))
            
            points, required, reward_name = matcher.db.cursor.fetchone()
            if points >= required:
                matcher.db.cursor.execute("""
                    UPDATE students
                    SET experience_points = experience_points - %s
                    WHERE student_id = %s
                """, (required, student_id))
                matcher.db.conn.commit()
                print(f"Successfully redeemed {reward_name}!")
            else:
                print("Not enough points!")
                
        elif choice == '6':
            break
            
        else:
            print("Invalid choice!")

if _name_ == "_main_":
    main()