class DisabledPeopleController < ApplicationController
  before_action :set_disabled_person, only: [:show, :update, :destroy]

  # GET /disabled_people
  def index
    @disabled_people = DisabledPerson.all.as_json(include: { phone_number: { only: [:number, :type] }, address: { except: [:_id, :address_id, :address_type] } })

    render json: @disabled_people
  end

  # GET /disabled_people/:cpf
  def show
    render json: format_response
  end

  # POST /disabled_people
  def create
    # Register disabled people
    # With address and phone number associated to them
    @disabled_person = DisabledPerson.new(disabled_person_params)
    @phone = PhoneNumber.create(phone_params)
    @address = Address.create(address_params)
    @disabled_person.phone_number = @phone
    @disabled_person.address = @address
    @disabled_person.health_center = HealthCenter.first
    if @disabled_person.save
      
      render json: format_response
      
    else
      render json: @disabled_person.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /disabled_people/1
  def update
    
    if @disabled_person.update(disabled_person_params)
      @disabled_person.health_center.update_attributes(health_center_params)
      @disabled_person.phone_number.update_attributes(phone_params)
      @disabled_person.address.update_attributes(address_params)
      
      render json: format_response
    else
      render json: @disabled_person.errors, status: :unprocessable_entity
    end
  end

  # DELETE /disabled_people/:cpf
  def destroy
    if @disabled_person.destroy
      render json: {"status": "deleted"}
    end
  end

  private

    def format_response
      @disabled_person.as_json(include: { phone_number: { only: [:number, :type] }, address: { except: [:_id, :address_id, :address_type] } })
    end
    # Use callbacks to share common setup or constraints between actions.
    def set_disabled_person
      @disabled_person = DisabledPerson.find_by(cpf: params[:cpf])
    end

    # Only allow a list of trusted parameters through.
    def disabled_person_params
      params.require(:disabled_person).permit(:name, :cpf, :born_date, :gender, 
                                                :father_name, :mother_name, :card_id, 
                                                :sus_id, :scholarity, :work_card_id, :acquisition_form, 
                                                :society_limitation, :social_situation, :infos_add, 
                                                :deficiency_type)
      end

    def address_params
      params.require(:address).permit(:cep, :street, :number, :neighborhood, :city, :state, :country, :complement)
    end

    def phone_params
      params.require(:phone_number).permit(:number, :type)
    end

    def health_center_params
      params.require(:health_center).permit(:name, :hc_code)
    end

    
end
