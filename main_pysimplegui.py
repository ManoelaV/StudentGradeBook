"""
Student GradeBook - Versão PySimpleGUI (sem problemas de dependências no Windows)
Interface simples e funcional para gerenciar notas de alunos
"""

import PySimpleGUI as sg
import os
from database import Database
from datetime import datetime
import threading

# Configurar tema
sg.theme('LightBlue2')
sg.set_options(font=('Arial', 10))

class StudentGradeBookGUI:
    def __init__(self):
        self.db = Database()
        self.current_student = None
        
    def student_list_window(self):
        """Janela principal - lista de alunos"""
        students = self.db.get_all_students()
        
        student_data = []
        for student in students:
            student_id, name, reg_num, photo_path, _, _ = student
            avg = self.db.get_student_average(student_id)
            student_data.append([name, reg_num or '-', f'{avg:.2f}', student_id])
        
        layout = [
            [sg.Text('📚 Caderneta de Notas', font=('Arial', 18, 'bold'))],
            [sg.Button('+ Novo Aluno', key='-ADD-'), sg.Button('Sair')],
            [sg.Table(
                values=student_data,
                headings=['Nome', 'Matrícula', 'Média', 'ID'],
                key='-TABLE-',
                display_row_numbers=False,
                num_rows=20,
                col_widths=[30, 15, 10, 5]
            )],
            [sg.Button('Ver Detalhes', key='-VIEW-'), 
             sg.Button('Editar', key='-EDIT-'),
             sg.Button('Excluir', key='-DELETE-', button_color=('white', 'red')),
             sg.Button('Atualizar', key='-REFRESH-')]
        ]
        
        window = sg.Window('Student GradeBook', layout, size=(800, 500), finalize=True)
        
        while True:
            event, values = window.read()
            
            if event in (sg.WINDOW_CLOSED, 'Sair'):
                break
            
            elif event == '-ADD-':
                window.hide()
                self.add_edit_student_window()
                window.un_hide()
                event = '-REFRESH-'
            
            elif event == '-VIEW-':
                try:
                    selected = values['-TABLE-']
                    if selected:
                        student_id = student_data[selected[0]][3]
                        window.hide()
                        self.student_detail_window(student_id)
                        window.un_hide()
                except:
                    sg.popup_error('Por favor, selecione um aluno')
            
            elif event == '-EDIT-':
                try:
                    selected = values['-TABLE-']
                    if selected:
                        student_id = student_data[selected[0]][3]
                        window.hide()
                        self.add_edit_student_window(student_id)
                        window.un_hide()
                except:
                    sg.popup_error('Por favor, selecione um aluno')
            
            elif event == '-DELETE-':
                try:
                    selected = values['-TABLE-']
                    if selected:
                        student_id = student_data[selected[0]][3]
                        if sg.popup_yes_no('Excluir aluno? Todos os dados serão perdidos!') == 'Yes':
                            self.db.delete_student(student_id)
                            event = '-REFRESH-'
                except:
                    sg.popup_error('Por favor, selecione um aluno')
            
            if event == '-REFRESH-':
                window.close()
                return
        
        window.close()
    
    def add_edit_student_window(self, student_id=None):
        """Janela para adicionar/editar aluno"""
        student = None
        title = 'Novo Aluno'
        selected_photo = None
        
        if student_id:
            student = self.db.get_student_by_id(student_id)
            title = f'Editar Aluno - {student[1]}'
        
        layout = [
            [sg.Text(title, font=('Arial', 14, 'bold'))],
            [sg.Text('Nome:'), sg.Input(student[1] if student else '', key='-NAME-', size=(40, 1))],
            [sg.Text('Matrícula:'), sg.Input(student[2] if student else '', key='-REG-', size=(40, 1))],
            [sg.Text('Foto:'), sg.Input(student[3] if student else '', key='-PHOTO-', disabled=True, size=(30, 1)),
             sg.FileBrowse('Procurar...', file_types=(('Imagens', '*.png *.jpg *.jpeg'),)),
             sg.Button('Limpar')],
            [sg.Button('Salvar'), sg.Button('Cancelar')]
        ]
        
        window = sg.Window(title, layout, finalize=True)
        
        while True:
            event, values = window.read()
            
            if event in (sg.WINDOW_CLOSED, 'Cancelar'):
                break
            
            elif event == 'Limpar':
                window['-PHOTO-'].update('')
            
            elif event == 'Salvar':
                name = values['-NAME-'].strip()
                reg_num = values['-REG-'].strip() or None
                photo_path = values['-PHOTO-'].strip() or None
                
                if not name:
                    sg.popup_error('Por favor, digite o nome do aluno')
                    continue
                
                # Copiar foto para pasta photos
                if photo_path and os.path.exists(photo_path):
                    if not os.path.exists('photos'):
                        os.makedirs('photos')
                    filename = f"student_{name.replace(' ', '_')}_{reg_num or 'noReg'}{os.path.splitext(photo_path)[1]}"
                    new_photo_path = os.path.join('photos', filename)
                    try:
                        import shutil
                        shutil.copy2(photo_path, new_photo_path)
                        photo_path = new_photo_path
                    except:
                        photo_path = None
                
                if student_id:
                    self.db.update_student(student_id, name, reg_num, photo_path)
                    sg.popup('Aluno atualizado com sucesso!')
                else:
                    result = self.db.add_student(name, reg_num, photo_path)
                    if result:
                        sg.popup('Aluno cadastrado com sucesso!')
                    else:
                        sg.popup_error('Erro: Número de matrícula já existe')
                        continue
                break
        
        window.close()
    
    def student_detail_window(self, student_id):
        """Janela de detalhes do aluno"""
        student = self.db.get_student_by_id(student_id)
        _, name, reg_num, _, _, _ = student
        
        while True:
            grades = self.db.get_student_grades(student_id)
            observations = self.db.get_student_observations(student_id)
            avg = self.db.get_student_average(student_id)
            
            grade_data = [[g[2], f'{g[3]}/{g[4]}', g[5], g[0]] for g in grades]
            obs_data = [[o[2][:50], o[3], o[0]] for o in observations]
            
            layout = [
                [sg.Text(f'📌 {name}', font=('Arial', 16, 'bold')),
                 sg.Text(f'Média: {avg:.2f}', font=('Arial', 14, 'bold'), text_color='green' if avg >= 6 else 'red')],
                [sg.Text(f'Matrícula: {reg_num or "N/A"}')],
                
                [sg.Text('📝 NOTAS', font=('Arial', 12, 'bold'))],
                [sg.Button('+ Adicionar Nota'), sg.Button('Excluir Nota')],
                [sg.Table(
                    values=grade_data,
                    headings=['Matéria', 'Nota', 'Data', 'ID'],
                    key='-GRADES-',
                    hide_vertical_scroll=False,
                    num_rows=8,
                    col_widths=[20, 10, 12, 5]
                )],
                
                [sg.Text('💬 OBSERVAÇÕES', font=('Arial', 12, 'bold'))],
                [sg.Multiline(size=(80, 10), key='-OBS-', disabled=False)],
                [sg.Button('Salvar Observação'), sg.Button('Excluir Obs Selecionada')],
                
                [sg.Text('📋 HISTÓRICO DE OBSERVAÇÕES', font=('Arial', 10, 'bold'))],
                [sg.Table(
                    values=obs_data,
                    headings=['Observação', 'Data', 'ID'],
                    key='-OBS-TABLE-',
                    hide_vertical_scroll=False,
                    num_rows=5,
                    col_widths=[50, 12, 5]
                )],
                
                [sg.Button('Voltar'), sg.Button('Excluir Aluno', button_color=('white', 'red'))]
            ]
            
            window = sg.Window(f'Detalhes - {name}', layout, size=(900, 900), finalize=True)
            
            event, values = window.read()
            window.close()
            
            if event in (sg.WINDOW_CLOSED, 'Voltar'):
                break
            
            elif event == '+ Adicionar Nota':
                subject = sg.popup_get_text('Matéria:')
                if subject:
                    grade_str = sg.popup_get_text('Nota:')
                    if grade_str:
                        try:
                            grade = float(grade_str)
                            max_grade_str = sg.popup_get_text('Nota Máxima:', default_text='10.0')
                            max_grade = float(max_grade_str) if max_grade_str else 10.0
                            self.db.add_grade(student_id, subject, grade, max_grade)
                            sg.popup('Nota adicionada!')
                        except:
                            sg.popup_error('Valores inválidos')
            
            elif event == 'Excluir Nota':
                try:
                    selected = values['-GRADES-']
                    if selected:
                        grade_id = grade_data[selected[0]][3]
                        self.db.delete_grade(grade_id)
                        sg.popup('Nota excluída!')
                except:
                    sg.popup_error('Selecione uma nota')
            
            elif event == 'Salvar Observação':
                observation = values['-OBS-'].strip()
                if observation:
                    self.db.add_observation(student_id, observation)
                    sg.popup('Observação salva!')
                else:
                    sg.popup_error('Digite uma observação')
            
            elif event == 'Excluir Obs Selecionada':
                try:
                    selected = values['-OBS-TABLE-']
                    if selected:
                        obs_id = obs_data[selected[0]][2]
                        self.db.delete_observation(obs_id)
                        sg.popup('Observação excluída!')
                except:
                    sg.popup_error('Selecione uma observação')
            
            elif event == 'Excluir Aluno':
                if sg.popup_yes_no('Excluir aluno e todos seus dados?') == 'Yes':
                    self.db.delete_student(student_id)
                    break
    
    def run(self):
        """Executa a aplicação"""
        while True:
            self.student_list_window()

if __name__ == '__main__':
    app = StudentGradeBookGUI()
    app.run()
