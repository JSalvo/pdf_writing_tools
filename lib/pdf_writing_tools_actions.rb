module PdfWritingToolsActions
  # Questa action contiene istruzioni per disegnare un "a capo" nel PDF
  def self.new_line_action
    [{ action_name: :draw_formatted_text, data: [{ text: "\n" }] }]
  end

  # Questa action, contiene istruzioni per disegnare nel pdf
  # indent_spaces spazi, in modo da creare degli extra spazi,
  # utili per i rientri
  def self.indent_action(indent_spaces = 4)
    [{
      action_name: :draw_formatted_text,
      data: [
        { text: Prawn::Text::NBSP * indent_spaces,
          styles: %i[bold white] }
      ]
    }]
  end

  # Questa action, contiene istruzioni per disegnare un "bullet", ossia
  # un oggetto grafico, tipo un segno di spunta accanto all'elemnto di
  # una lista
  def self.bullet_action
    [
      {
        action_name: :draw_image, data:
        {
          url: 'public/bullet.png' # Pallino
        }
      }
    ]
  end

  # Esegue last_action, oppure concatena i dati di action e di last_action
  def self.text_action(pdf, action, last_action_name, data)
    if last_action_name.nil?
      data = action[:data]
    elsif last_action_name == :draw_formatted_text
      data += action[:data]
    else
      execute_action(pdf, last_action_name, data)
      data = action[:data]
    end
    [:draw_formatted_text, data]
  end

  # Mentre la "scrittura/disegno" del testo, puo' essere "concatenato", nel caso
  # delle immagini no. Una action sulla immagine, pertanto interrompe la
  # possibilita' di concatenare i data delle action di testo. Pertanto, eseguo
  # in ogni caso last_action, a meno che last_action non sia nil (ossia action
  # e' la prima azione della lista)
  def self.img_action(pdf, action, last_action_name, data)
    execute_action(pdf, last_action_name, data) unless last_action_name.nil?
    [:draw_image, action[:data]]
  end

  # Esegue un azione, andando a scrivere del testo nel PDF oppure un'immagine
  def self.execute_action(pdf, action_name, data)
    if action_name == :draw_formatted_text
      pdf.formatted_text(data, align: :left)
    elsif action_name == :draw_image
      current_cursor_position = pdf.cursor
      pdf.move_cursor_to(current_cursor_position - 3)
      pdf.image(data[:url], height: 6, width: 6)
      pdf.move_cursor_to(current_cursor_position)
    end
  end

  # Esegue le azioni, andando a concatenare quelle "contigue" nella lista,
  # che riguardano la scrittura di testo
  def self.execute_actions(pdf, actions, last_actn_name, data)
    actions.each do |action|
      if action[:action_name] == :draw_formatted_text
        last_actn_name, data = text_action(pdf, action, last_actn_name, data)
      elsif action[:action_name] == :draw_image
        last_actn_name, data = img_action(pdf, action, last_actn_name, data)
      end
    end
    execute_action(pdf, last_actn_name, data)
  end
end
